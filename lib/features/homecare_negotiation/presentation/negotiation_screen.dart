// lib/features/homecare_negotiation/presentation/negotiation_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/negotiation_providers.dart';
import 'negotiation_controller.dart';
import '../../payments/presentation/payment_screen.dart';

/// Negotiation screen for price bargaining (Indrive-style)
class NegotiationScreen extends ConsumerStatefulWidget {
  const NegotiationScreen({
    super.key,
    required this.requestId,
    required this.userRole,
  });

  final String requestId;
  final String userRole;

  @override
  ConsumerState<NegotiationScreen> createState() => _NegotiationScreenState();
}

class _NegotiationScreenState extends ConsumerState<NegotiationScreen> {
  final _priceController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _priceController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _proposePrice() async {
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    await ref.read(negotiationControllerProvider.notifier).proposePrice(
          requestId: widget.requestId,
          price: price,
        );

    _priceController.clear();
    _scrollToBottom();
  }

  Future<void> _counterOffer() async {
    final price = double.tryParse(_priceController.text);
    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return;
    }

    await ref.read(negotiationControllerProvider.notifier).counterOffer(
          requestId: widget.requestId,
          price: price,
          offeredBy: widget.userRole,
        );

    _priceController.clear();
    _scrollToBottom();
  }

  Future<void> _acceptOffer() async {
    await ref.read(negotiationControllerProvider.notifier).acceptOffer(
          requestId: widget.requestId,
        );

    if (!mounted) return;

    // Navigate to payment screen
    final state =
        await ref.read(negotiationStateProvider(widget.requestId).future);
    final negotiatedPrice = state['negotiated_price'] as double?;

    if (negotiatedPrice != null && widget.userRole == 'patient') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentScreen(
            requestId: widget.requestId,
            negotiatedPrice: negotiatedPrice,
            platformFee: 500.0,
          ),
        ),
      );
    }
  }

  Future<void> _declineOffer() async {
    await ref.read(negotiationControllerProvider.notifier).declineOffer(
          requestId: widget.requestId,
          declinedBy: widget.userRole,
          reason: 'Price not acceptable',
        );

    if (!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final negotiationState =
        ref.watch(negotiationStateProvider(widget.requestId));
    final negotiationHistory =
        ref.watch(negotiationHistoryProvider(widget.requestId));

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.primary,
        title: Text(
          'Price Negotiation',
          style: textTheme.headlineSmall?.copyWith(color: Colors.white),
        ),
        elevation: 0,
      ),
      body: negotiationState.when(
        data: (state) {
          final status = state['status'] as String;
          final currentOffer = state['current_offer'] as double?;
          final offeredBy = state['offered_by'] as String?;
          final negotiationRound = state['negotiation_round'] as int? ?? 0;

          final isMyTurn = offeredBy != null && offeredBy != widget.userRole;
          final isPriceAgreed = status == 'price_agreed';
          final maxRoundsReached = negotiationRound >= 5;

          return Column(
            children: [
              // Status Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: isPriceAgreed
                    ? Colors.green.shade50
                    : isMyTurn
                        ? Colors.blue.shade50
                        : Colors.grey.shade100,
                child: Row(
                  children: [
                    Icon(
                      isPriceAgreed
                          ? Icons.check_circle
                          : isMyTurn
                              ? Icons.notifications_active
                              : Icons.hourglass_empty,
                      color: isPriceAgreed
                          ? Colors.green.shade700
                          : isMyTurn
                              ? Colors.blue.shade700
                              : Colors.grey.shade600,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        isPriceAgreed
                            ? '✅ Price agreed! ${currentOffer?.toStringAsFixed(2)} DA'
                            : isMyTurn
                                ? '💬 Your turn to respond (Round $negotiationRound/5)'
                                : '⏳ Waiting for response...',
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isPriceAgreed
                              ? Colors.green.shade900
                              : isMyTurn
                                  ? Colors.blue.shade900
                                  : Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Negotiation History (Chat-like)
              Expanded(
                child: negotiationHistory.when(
                  data: (history) {
                    _scrollToBottom();
                    return ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: history.length,
                      itemBuilder: (context, index) {
                        final offer = history[index];
                        final amount = offer['amount'] as double;
                        final offerBy = offer['offered_by'] as String;
                        final timestamp = offer['timestamp'] as String;
                        final isMe = offerBy == widget.userRole;

                        return _buildOfferBubble(
                          amount: amount,
                          offeredBy: offerBy,
                          timestamp: timestamp,
                          isMe: isMe,
                          theme: theme,
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),

              // Price Agreed - Show Total
              if (isPriceAgreed && currentOffer != null)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    border: Border(
                      top: BorderSide(color: Colors.green.shade200),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Service Price:', style: textTheme.bodyLarge),
                          Text(
                            '${currentOffer.toStringAsFixed(2)} DA',
                            style: textTheme.titleMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Platform Fee:', style: textTheme.bodyLarge),
                          Text(
                            '+500.00 DA',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 24, thickness: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total to Pay:',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${(currentOffer + 500).toStringAsFixed(2)} DA',
                            style: textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                      if (widget.userRole == 'patient') ...[
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PaymentScreen(
                                  requestId: widget.requestId,
                                  negotiatedPrice: currentOffer,
                                  platformFee: 500.0,
                                ),
                              ),
                            );
                          },
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(double.infinity, 52),
                            backgroundColor: Colors.green.shade600,
                          ),
                          child: Text(
                            'Proceed to Payment',
                            style: textTheme.titleMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

              // Input Area (only if not agreed and it's your turn)
              if (!isPriceAgreed && isMyTurn && !maxRoundsReached)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _priceController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              decoration: InputDecoration(
                                labelText: 'Your Counter-Offer (DA)',
                                hintText: 'Enter amount',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                suffixText: 'DA',
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _counterOffer,
                            icon: const Icon(Icons.send),
                            label: const Text('Send'),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _acceptOffer,
                              icon: const Icon(Icons.check_circle_outline),
                              label: Text(
                                'Accept ${currentOffer?.toStringAsFixed(0)} DA',
                              ),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.green.shade700,
                                side: BorderSide(color: Colors.green.shade300),
                                minimumSize: const Size(0, 48),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _declineOffer,
                              icon: const Icon(Icons.cancel_outlined),
                              label: const Text('Decline'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.red.shade700,
                                side: BorderSide(color: Colors.red.shade300),
                                minimumSize: const Size(0, 48),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

              // Max rounds reached
              if (maxRoundsReached && !isPriceAgreed)
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.orange.shade50,
                  child: Text(
                    '⚠️ Maximum negotiation rounds (5) reached. Please accept or decline.',
                    style: textTheme.bodyMedium?.copyWith(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildOfferBubble({
    required double amount,
    required String offeredBy,
    required String timestamp,
    required bool isMe,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final time = DateTime.parse(timestamp);
    final timeStr = DateFormat('HH:mm').format(time);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isMe ? colorScheme.primary : colorScheme.surfaceVariant,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMe ? 16 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isMe ? 'You' : (offeredBy == 'partner' ? 'Partner' : 'Patient'),
              style: textTheme.labelSmall?.copyWith(
                color: isMe ? Colors.white70 : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(2)} DA',
              style: textTheme.headlineSmall?.copyWith(
                color: isMe ? Colors.white : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              timeStr,
              style: textTheme.labelSmall?.copyWith(
                color: isMe
                    ? Colors.white60
                    : colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
