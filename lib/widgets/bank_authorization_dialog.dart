import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Demo 3DS-style step: OTP is shown on screen — no SMS is sent.
Future<bool?> showBankAuthorizationDialog(
  BuildContext context, {
  required String expectedOtp,
  required String mobileLastTwo,
}) {
  return showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => BankAuthorizationDialog(
      expectedOtp: expectedOtp,
      mobileLastTwo: mobileLastTwo,
    ),
  );
}

class BankAuthorizationDialog extends StatefulWidget {
  const BankAuthorizationDialog({
    super.key,
    required this.expectedOtp,
    required this.mobileLastTwo,
  });

  final String expectedOtp;
  final String mobileLastTwo;

  @override
  State<BankAuthorizationDialog> createState() =>
      _BankAuthorizationDialogState();
}

class _BankAuthorizationDialogState extends State<BankAuthorizationDialog> {
  static const _mintBg = Color(0xFFF0F9F9);
  static const _teal = Color(0xFF52948C);

  final _otpCtrl = TextEditingController();
  bool _busy = false;

  @override
  void dispose() {
    _otpCtrl.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final entered = _otpCtrl.text.replaceAll(RegExp(r'\D'), '');
    if (entered.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter the 6-digit OTP.')),
      );
      return;
    }
    if (entered != widget.expectedOtp) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incorrect OTP. Check the demo code below.')),
      );
      return;
    }
    setState(() => _busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 220));
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      backgroundColor: _mintBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: IconButton(
                  onPressed: _busy ? null : () => Navigator.of(context).pop(false),
                  icon: Icon(Icons.close, color: Colors.grey.shade700),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
              ),
              Text(
                'Bank Authorization',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: Colors.brown.shade900,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Confirm your payment with the one-time password',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade900,
                      height: 1.4,
                    ),
                    children: [
                      const TextSpan(
                        text:
                            "We've sent a one-time password (OTP) to your registered mobile number ending in ",
                      ),
                      TextSpan(
                        text: '****${widget.mobileLastTwo}',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Enter 6-Digit OTP',
                style: TextStyle(
                  color: Colors.brown.shade900,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                  fontFamily: 'serif',
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _otpCtrl,
                keyboardType: TextInputType.number,
                maxLength: 6,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  letterSpacing: 6,
                  fontWeight: FontWeight.w700,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '000000',
                  hintStyle: TextStyle(
                    color: Colors.grey.shade400,
                    letterSpacing: 6,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.teal.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: Colors.teal.shade200),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: _teal, width: 1.6),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                ],
              ),
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFDE7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.amber.shade600, width: 1),
                ),
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Demo Mode: Your OTP is ',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.brown.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      widget.expectedOtp,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: Colors.brown.shade900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy
                          ? null
                          : () => Navigator.of(context).pop(false),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _teal,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.teal.shade300),
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
                      onPressed: _busy ? null : _verify,
                      style: FilledButton.styleFrom(
                        backgroundColor: _teal,
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
                          : const Text(
                              'Verify & Pay',
                              style: TextStyle(fontWeight: FontWeight.w800),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
