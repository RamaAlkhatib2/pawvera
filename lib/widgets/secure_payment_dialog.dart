import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'bank_authorization_dialog.dart';

/// PCI-safe payload only — never persist full PAN, expiry, or CVC.
class SecureCardPaymentMeta {
  SecureCardPaymentMeta({
    required this.brand,
    required this.lastFourDigits,
    required this.cardholderName,
  });

  final String brand;
  final String lastFourDigits;
  final String cardholderName;

  Map<String, dynamic> toFirestoreMap() => {
        'brand': brand,
        'lastFourDigits': lastFourDigits,
        'cardholderName': cardholderName,
      };
}

Future<SecureCardPaymentMeta?> showSecurePaymentDialog(
  BuildContext context, {
  required double totalJod,
  required String deliveryPhoneDigits,
}) {
  return showDialog<SecureCardPaymentMeta>(
    context: context,
    barrierDismissible: false,
    builder: (context) => SecurePaymentDialog(
      totalJod: totalJod,
      deliveryPhoneDigits: deliveryPhoneDigits,
    ),
  );
}

String phoneLastTwoForDisplay(String raw) {
  final d = raw.replaceAll(RegExp(r'\D'), '');
  if (d.length >= 2) return d.substring(d.length - 2);
  return '12';
}

String _demoLastFourDigits(String digitsOnly) {
  if (digitsOnly.isEmpty) return '0000';
  if (digitsOnly.length >= 4) {
    return digitsOnly.substring(digitsOnly.length - 4);
  }
  return digitsOnly.padLeft(4, '0');
}

class _CardDigitsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final d = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 19) {
      return oldValue;
    }
    final buf = StringBuffer();
    for (var i = 0; i < d.length; i++) {
      if (i > 0 && i % 4 == 0) buf.write(' ');
      buf.write(d[i]);
    }
    final t = buf.toString();
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var d = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (d.length > 4) d = d.substring(0, 4);
    String t;
    if (d.length <= 2) {
      t = d;
    } else {
      t = '${d.substring(0, 2)}/${d.substring(2)}';
    }
    return TextEditingValue(
      text: t,
      selection: TextSelection.collapsed(offset: t.length),
    );
  }
}

class SecurePaymentDialog extends StatefulWidget {
  const SecurePaymentDialog({
    super.key,
    required this.totalJod,
    required this.deliveryPhoneDigits,
  });

  final double totalJod;
  /// Raw phone field from checkout (digits used only for ****XX mask).
  final String deliveryPhoneDigits;

  @override
  State<SecurePaymentDialog> createState() => _SecurePaymentDialogState();
}

class _SecurePaymentDialogState extends State<SecurePaymentDialog> {
  static const _brown = Color(0xFF5D4037);
  static const _payTeal = Color(0xFF52948C);
  static const _mintBg = Color(0xFFF0F9F9);

  final _cardNumberCtrl = TextEditingController();
  final _expiryCtrl = TextEditingController();
  final _cvcCtrl = TextEditingController();
  final _nameCtrl = TextEditingController();

  String _brand = 'visa';
  bool _busy = false;

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvcCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  int _expectedCvcLen() {
    return _brand == 'amex' ? 4 : 3;
  }

  /// Demo-only: no real card network validation (Luhn, expiry, etc.).
  Future<void> _submit() async {
    final digits = _cardNumberCtrl.text.replaceAll(RegExp(r'\D'), '');
    final name = _nameCtrl.text.trim();
    final displayName =
        name.length >= 2 ? name.toUpperCase() : 'DEMO CUSTOMER';

    final last4 = _demoLastFourDigits(digits);

    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (!mounted) return;
    setState(() => _busy = false);

    final otp = (100000 + Random().nextInt(900000)).toString();
    final verified = await showBankAuthorizationDialog(
      context,
      expectedOtp: otp,
      mobileLastTwo: phoneLastTwoForDisplay(widget.deliveryPhoneDigits),
    );
    if (!mounted || verified != true) return;

    Navigator.of(context).pop(
      SecureCardPaymentMeta(
        brand: _brand,
        lastFourDigits: last4,
        cardholderName: displayName,
      ),
    );
  }

  InputDecoration _dec(String label, String hint) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: _brown,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _payTeal, width: 1.4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final totalStr = widget.totalJod.toStringAsFixed(2);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: _mintBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lock_outline_rounded, color: Colors.brown.shade700),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Secure Payment',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Colors.brown.shade800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Enter your card details to complete the payment',
                          style: TextStyle(
                            fontSize: 12.5,
                            color: Colors.grey.shade700,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _busy ? null : () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.green.shade100),
                      ),
                      child: Row(
                        children: [
                          Text(
                            'Total to Pay',
                            style: TextStyle(
                              color: Colors.brown.shade800,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$totalStr JOD',
                            style: const TextStyle(
                              color: Color(0xFF1B5E20),
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Select Card Type',
                      style: TextStyle(
                        color: _brown,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 88,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _BrandChip(
                            selected: _brand == 'visa',
                            onTap: () => setState(() => _brand = 'visa'),
                            bg: const Color(0xFF1A1F71),
                            child: const Center(
                              child: Text(
                                'VISA',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                          _BrandChip(
                            selected: _brand == 'mastercard',
                            onTap: () => setState(() => _brand = 'mastercard'),
                            bg: Colors.white,
                            child: const _MastercardCircles(),
                          ),
                          _BrandChip(
                            selected: _brand == 'amex',
                            onTap: () => setState(() => _brand = 'amex'),
                            bg: const Color(0xFF006FCF),
                            child: const Center(
                              child: Text(
                                'AMEX',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          _BrandChip(
                            selected: _brand == 'discover',
                            onTap: () => setState(() => _brand = 'discover'),
                            bg: const Color(0xFFFF6000),
                            child: const Center(
                              child: Text(
                                'DISC',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _cardNumberCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [_CardDigitsFormatter()],
                      decoration: _dec(
                        'Card Number',
                        '1234 5678 9012 3456',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _expiryCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [_ExpiryFormatter()],
                            decoration: _dec('Expiry Date', 'MM/YY'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            key: ValueKey<String>('cvc_$_brand'),
                            controller: _cvcCtrl,
                            keyboardType: TextInputType.number,
                            obscureText: true,
                            maxLength: _expectedCvcLen(),
                            buildCounter: (
                              context, {
                              required currentLength,
                              required isFocused,
                              maxLength,
                            }) =>
                                const SizedBox.shrink(),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: _dec('CVC', _brand == 'amex' ? '1234' : '123'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.characters,
                      decoration: _dec('Cardholder Name', 'JOHN DOE'),
                    ),
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.verified_user_outlined,
                            color: Colors.green.shade700,
                            size: 22,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Your payment information is encrypted and secure. '
                              'We never store your card details.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade800,
                                height: 1.35,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _busy
                                ? null
                                : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: _brown,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              side: BorderSide(color: Colors.grey.shade400),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: FilledButton(
                            onPressed: _busy ? null : _submit,
                            style: FilledButton.styleFrom(
                              backgroundColor: _payTeal,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _busy
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Pay $totalStr JOD',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BrandChip extends StatelessWidget {
  const _BrandChip({
    required this.selected,
    required this.onTap,
    required this.bg,
    required this.child,
  });

  final bool selected;
  final VoidCallback onTap;
  final Color bg;
  final Widget child;

  static const _teal = Color(0xFF52948C);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 76,
              height: 48,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: selected ? _teal : Colors.grey.shade300,
                  width: selected ? 2.2 : 1,
                ),
                boxShadow: [
                  if (bg == Colors.white)
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: child,
              ),
            ),
            const SizedBox(height: 4),
            if (selected)
              Icon(Icons.check_circle, size: 16, color: Colors.blue.shade700)
            else
              const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MastercardCircles extends StatelessWidget {
  const _MastercardCircles();

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          left: 10,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFFEB001B),
              shape: BoxShape.circle,
            ),
          ),
        ),
        Positioned(
          right: 10,
          child: Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: Color(0xFFF79E1B),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }
}
