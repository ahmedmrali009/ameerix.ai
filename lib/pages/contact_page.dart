import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../config/routes.dart';
import '../core/breakpoints.dart';
import '../core/validators.dart';
import '../l10n/app_localizations.dart';
import '../localization/locale_controller.dart';
import '../models/contact_request.dart';
import '../sections/shared/page_hero.dart';
import '../services/app_services.dart';
import '../services/contact/contact_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../widgets/buttons.dart';
import '../widgets/cards.dart';
import '../widgets/page_scaffold.dart';
import '../widgets/pressable.dart';
import '../widgets/responsive_grid.dart';
import '../widgets/section.dart';
import '../widgets/text_blocks.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    return PageScaffold(
      path: AppRoutes.contact,
      metaTitle: (l) => l.metaTitleContact,
      metaDescription: (l) => l.metaDescContact,
      sections: [
        PageHero(eyebrow: l.contactEyebrow, title: l.contactTitle, body: l.contactBody),
        Section(
          tone: SectionTone.muted,
          child: SplitLayout(
            breakpoint: 980,
            gap: 48,
            startFlex: 7,
            endFlex: 4,
            start: const ContactForm(),
            end: const _ContactAside(),
          ),
        ),
      ],
    );
  }
}

/// Demo / contact form. Validation is client-side; delivery is delegated to
/// the configured [ContactService] (see README → "Connecting the form").
class ContactForm extends StatefulWidget {
  const ContactForm({super.key, this.initialType = ContactRequestType.demo});

  final ContactRequestType initialType;

  @override
  State<ContactForm> createState() => _ContactFormState();
}

enum _FormStatus { idle, submitting, success, notConfigured, failed }

class _ContactFormState extends State<ContactForm> {
  final _formKey = GlobalKey<FormState>();
  late ContactRequestType _type = widget.initialType;

  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _company = TextEditingController();
  final _jobTitle = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _country = TextEditingController();
  final _message = TextEditingController();
  IndustryOption? _industry;
  bool _consent = false;
  bool _consentError = false;
  _FormStatus _status = _FormStatus.idle;
  AutovalidateMode _autovalidate = AutovalidateMode.disabled;

  @override
  void dispose() {
    for (final c in [_firstName, _lastName, _company, _jobTitle, _email, _phone, _country, _message]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState?.validate() ?? false;
    setState(() {
      _consentError = !_consent;
      _autovalidate = AutovalidateMode.onUserInteraction;
    });
    if (!valid || !_consent || _industry == null) return;

    setState(() => _status = _FormStatus.submitting);
    final request = ContactRequest(
      type: _type,
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      company: _company.text.trim(),
      jobTitle: _jobTitle.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      country: _country.text.trim(),
      industry: _industry!,
      message: _message.text.trim(),
      language: LocaleScope.read(context).language.code,
      consent: _consent,
    );
    final result = await AppServices.of(context).contact.submit(request);
    if (!mounted) return;
    setState(() {
      _status = switch (result.status) {
        SubmissionStatus.success => _FormStatus.success,
        SubmissionStatus.notConfigured => _FormStatus.notConfigured,
        SubmissionStatus.failed => _FormStatus.failed,
      };
    });
  }

  void _reset() {
    _formKey.currentState?.reset();
    for (final c in [_firstName, _lastName, _company, _jobTitle, _email, _phone, _country, _message]) {
      c.clear();
    }
    setState(() {
      _industry = null;
      _consent = false;
      _consentError = false;
      _status = _FormStatus.idle;
      _autovalidate = AutovalidateMode.disabled;
    });
  }

  String _industryLabel(AppLocalizations l, IndustryOption o) => switch (o) {
        IndustryOption.gourmetFood => l.indFoodName,
        IndustryOption.cosmetics => l.indCosmeticsName,
        IndustryOption.furniture => l.indFurnitureName,
        IndustryOption.hospitalityConstruction => l.indHospitalityName,
        IndustryOption.gccTrade => l.industryOptionGccTrade,
        IndustryOption.advisory => l.industryOptionAdvisory,
        IndustryOption.other => l.industryOptionOther,
      };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    final isRtl = Directionality.of(context) == TextDirection.rtl;
    final ltrAlign = isRtl ? TextAlign.right : TextAlign.left;

    return HoverCard(
      hoverable: false,
      padding: EdgeInsets.all(Breakpoints.value<double>(context, mobile: 20, tablet: 32, laptop: 40)),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 250),
        alignment: AlignmentDirectional.topStart,
        child: _status == _FormStatus.success
            ? _SuccessPanel(onReset: _reset)
            : Form(
                key: _formKey,
                autovalidateMode: _autovalidate,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _TypeSwitch(
                        value: _type,
                        onChanged: (v) => setState(() => _type = v),
                      ),
                      const Gap(28),
                      _Pair(
                        first: _field(
                          controller: _firstName,
                          label: l.fieldFirstName,
                          validator: (v) => Validators.required(l, v),
                          hints: const [AutofillHints.givenName],
                        ),
                        second: _field(
                          controller: _lastName,
                          label: l.fieldLastName,
                          validator: (v) => Validators.required(l, v),
                          hints: const [AutofillHints.familyName],
                        ),
                      ),
                      _Pair(
                        first: _field(
                          controller: _company,
                          label: l.fieldCompany,
                          validator: (v) => Validators.required(l, v),
                          hints: const [AutofillHints.organizationName],
                        ),
                        second: _field(
                          controller: _jobTitle,
                          label: l.fieldJobTitle,
                          validator: (v) => Validators.required(l, v),
                          hints: const [AutofillHints.jobTitle],
                        ),
                      ),
                      _Pair(
                        first: _field(
                          controller: _email,
                          label: l.fieldEmail,
                          validator: (v) => Validators.email(l, v),
                          hints: const [AutofillHints.email],
                          keyboard: TextInputType.emailAddress,
                          ltr: true,
                          align: ltrAlign,
                        ),
                        second: _field(
                          controller: _phone,
                          label: '${l.fieldPhone} (${l.labelOptional})',
                          validator: (v) => Validators.optionalPhone(l, v),
                          hints: const [AutofillHints.telephoneNumber],
                          keyboard: TextInputType.phone,
                          ltr: true,
                          align: ltrAlign,
                          formatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9+()\-.\s]'))],
                        ),
                      ),
                      _Pair(
                        first: _field(
                          controller: _country,
                          label: l.fieldCountry,
                          validator: (v) => Validators.required(l, v),
                          hints: const [AutofillHints.countryName],
                        ),
                        second: Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: DropdownButtonFormField<IndustryOption>(
                            initialValue: _industry,
                            isExpanded: true,
                            decoration: InputDecoration(labelText: l.fieldIndustry),
                            items: [
                              for (final o in IndustryOption.values)
                                DropdownMenuItem(
                                  value: o,
                                  child: Text(_industryLabel(l, o), overflow: TextOverflow.ellipsis),
                                ),
                            ],
                            onChanged: (v) => setState(() => _industry = v),
                            validator: (v) => v == null ? l.valSelect : null,
                          ),
                        ),
                      ),
                      _field(
                        controller: _message,
                        label: l.fieldMessage,
                        hint: _type == ContactRequestType.demo ? l.fieldMessageHintDemo : l.fieldMessageHintContact,
                        validator: (v) => Validators.message(l, v),
                        maxLines: 6,
                        maxLength: Validators.messageMaxLength,
                        keyboard: TextInputType.multiline,
                      ),
                      const Gap(4),
                      _ConsentRow(
                        value: _consent,
                        error: _consentError ? l.valConsent : null,
                        label: l.consentLabel,
                        onChanged: (v) => setState(() {
                          _consent = v;
                          if (v) _consentError = false;
                        }),
                      ),
                      const Gap(24),
                      Tone(
                        palette: TonePalette.light,
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 12,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            AppButton(
                              label: _status == _FormStatus.submitting
                                  ? l.submitting
                                  : (_type == ContactRequestType.demo ? l.submitDemo : l.submitContact),
                              onPressed: _status == _FormStatus.submitting ? null : _submit,
                              loading: _status == _FormStatus.submitting,
                              showArrow: _status != _FormStatus.submitting,
                            ),
                            Text(l.privacyNote, style: t.caption.copyWith(color: AppColors.grey500)),
                          ],
                        ),
                      ),
                      if (_status == _FormStatus.notConfigured || _status == _FormStatus.failed) ...[
                        const Gap(20),
                        Semantics(
                          liveRegion: true,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFEF3F2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFFECDCA)),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.error_outline, size: 18, color: Color(0xFFB42318)),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _status == _FormStatus.notConfigured ? l.errorNotConfigured : l.errorGeneric,
                                    style: t.bodySmall.copyWith(color: const Color(0xFF912018)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String label,
    required String? Function(String?) validator,
    String? hint,
    List<String> hints = const [],
    TextInputType? keyboard,
    bool ltr = false,
    TextAlign align = TextAlign.start,
    int maxLines = 1,
    int? maxLength,
    List<TextInputFormatter>? formatters,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        validator: validator,
        autofillHints: hints,
        keyboardType: keyboard,
        textDirection: ltr ? TextDirection.ltr : null,
        textAlign: align,
        maxLines: maxLines,
        minLines: maxLines > 1 ? 4 : 1,
        maxLength: maxLength ?? Validators.maxLength,
        maxLengthEnforcement: MaxLengthEnforcement.enforced,
        inputFormatters: formatters,
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        style: const TextStyle(fontSize: 15.5, color: AppColors.black),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          counterText: '',
        ),
      ),
    );
  }
}

/// Two fields side by side when there is room, stacked otherwise.
class _Pair extends StatelessWidget {
  const _Pair({required this.first, required this.second});
  final Widget first;
  final Widget second;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth < 520) {
          return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [first, second]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: first), const SizedBox(width: 16), Expanded(child: second)],
        );
      },
    );
  }
}

class _TypeSwitch extends StatelessWidget {
  const _TypeSwitch({required this.value, required this.onChanged});

  final ContactRequestType value;
  final ValueChanged<ContactRequestType> onChanged;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);

    Widget option(ContactRequestType type, String label) {
      final selected = value == type;
      return Expanded(
        child: Semantics(
          selected: selected,
          inMutuallyExclusiveGroup: true,
          child: Pressable(
            onTap: () => onChanged(type),
            semanticLabel: label,
            excludeChildSemantics: true,
            builder: (context, s) => AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.black : (s.hovered ? AppColors.white : Colors.transparent),
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: s.focused ? AppColors.black : Colors.transparent),
              ),
              child: Text(
                label,
                textAlign: TextAlign.center,
                style: t.label.copyWith(fontSize: 14.5, color: selected ? AppColors.white : AppColors.grey600),
              ),
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.mist,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.lineLight),
      ),
      child: Row(
        children: [
          option(ContactRequestType.demo, l.tabDemo),
          const SizedBox(width: 4),
          option(ContactRequestType.contact, l.tabContact),
        ],
      ),
    );
  }
}

class _ConsentRow extends StatelessWidget {
  const _ConsentRow({required this.value, required this.onChanged, required this.label, this.error});

  final bool value;
  final ValueChanged<bool> onChanged;
  final String label;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final t = AppTypography.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MergeSemantics(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: value,
                onChanged: (v) => onChanged(v ?? false),
                side: BorderSide(color: error != null ? const Color(0xFFB42318) : AppColors.grey500, width: 1.4),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: GestureDetector(
                  onTap: () => onChanged(!value),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(label, style: t.bodySmall.copyWith(color: AppColors.grey600)),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsetsDirectional.only(start: 12, top: 4),
            child: Text(error!, style: t.caption.copyWith(color: const Color(0xFFB42318))),
          ),
      ],
    );
  }
}

class _SuccessPanel extends StatelessWidget {
  const _SuccessPanel({required this.onReset});
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);
    return Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const IconBadge(Icons.check, size: 52, filled: true),
            const Gap(24),
            Heading(l.successTitle, style: t.h2, level: 2),
            const Gap(12),
            Text(l.successBody, style: t.lead.copyWith(color: AppColors.grey600)),
            const Gap(28),
            AppButton(label: l.sendAnother, onPressed: onReset, variant: ButtonVariant.secondary),
          ],
        ),
      ),
    );
  }
}

class _ContactAside extends StatelessWidget {
  const _ContactAside();

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final t = AppTypography.of(context);

    Widget block(String title, Widget child) => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.usesUppercase ? title.toUpperCase() : title,
              style: t.eyebrow.copyWith(color: AppColors.grey500),
            ),
            const Gap(14),
            child,
          ],
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Tone(
          palette: TonePalette.dark,
          child: Container(
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(color: AppColors.black, borderRadius: BorderRadius.circular(16)),
            child: block(
              l.contactAsideTitle,
              MarkerList(items: [l.aside1, l.aside2, l.aside3], marker: ListMarker.check, small: true),
            ),
          ),
        ),
        const Gap(16),
        HoverCard(
          hoverable: false,
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              block(
                l.contactLocationTitle,
                Text('${l.cityBarcelona}, ${l.countrySpain}', style: t.body.copyWith(color: AppColors.black)),
              ),
              const Gap(24),
              block(
                l.contactMarketsTitle,
                Text('${l.countryUae} · ${l.countryKsa}', style: t.body.copyWith(color: AppColors.black)),
              ),
            ],
          ),
        ),
        const Gap(16),
        NoteBox(l.footerDisclaimer),
      ],
    );
  }
}
