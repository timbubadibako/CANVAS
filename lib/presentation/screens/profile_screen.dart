import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/studio_toast.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:image_picker/image_picker.dart';
import 'auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ImagePicker _picker = ImagePicker();
  
  // Profile State
  String userName = "Studio Felix";
  double weight = 72.5;
  int height = 178;
  int calorieGoal = 2000;
  String? profileImageUrl = 'https://api.dicebear.com/7.x/avataaars/svg?seed=Felix';
  File? _localImagePath;

  // Account Reveal State
  bool _isAccountExpanded = false;
  final TextEditingController _emailController = TextEditingController(text: "artist@canvas.io");
  final TextEditingController _phoneController = TextEditingController(text: "+62 812 3456 7890");
  final TextEditingController _passController = TextEditingController(text: "••••••••");

  // Settings Toggles
  bool _notifEnabled = true;
  bool _isDarkMode = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Widget _stagger(int index, Widget child) {
    final animation = CurvedAnimation(
      parent: _controller,
      curve: Interval(index * 0.08, (index * 0.1 + 0.5).clamp(0, 1), curve: Curves.easeOutQuart),
    );
    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(animation),
        child: child,
      ),
    );
  }

  // --- IMAGE LOGIC ---
  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source, maxWidth: 512, maxHeight: 512, imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _localImagePath = File(pickedFile.path);
          profileImageUrl = null;
        });
        if (mounted) StudioToast.show(context, 'AVATAR UPDATED', icon: LucideIcons.image);
      }
    } catch (e) {
      if (mounted) StudioToast.show(context, 'CAMERA ERROR', icon: LucideIcons.alertCircle);
    }
  }

  void _removeAvatar() {
    setState(() {
      _localImagePath = null;
      profileImageUrl = null;
    });
    StudioToast.show(context, 'AVATAR REMOVED', icon: LucideIcons.trash2);
  }

  // --- MODALS & DIALOGS ---
  void _showEditProfile() {
    final nameCtrl = TextEditingController(text: userName);
    final heightCtrl = TextEditingController(text: height.toString());
    final weightCtrl = TextEditingController(text: weight.toString());
    final goalCtrl = TextEditingController(text: calorieGoal.toString());

    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 32, right: 32, top: 32),
        decoration: const BoxDecoration(color: AppColors.deepSlate, borderRadius: BorderRadius.vertical(top: Radius.circular(48))),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white12, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 32),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text('EDIT STUDIO PROFILE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.5, color: AppColors.studioIndigo)),
              TextButton(onPressed: () { Navigator.pop(context); _showAvatarPicker(); }, child: const Text('Edit Photo', style: TextStyle(fontSize: 12))),
            ]),
            const SizedBox(height: 24),
            _buildInnerField('Artist Name', nameCtrl),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: _buildInnerField('Height (cm)', heightCtrl, isNum: true)),
              const SizedBox(width: 16),
              Expanded(child: _buildInnerField('Weight (kg)', weightCtrl, isNum: true)),
            ]),
            const SizedBox(height: 16),
            _buildInnerField('Calorie Goal', goalCtrl, isNum: true),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  userName = nameCtrl.text;
                  height = int.tryParse(heightCtrl.text) ?? height;
                  weight = double.tryParse(weightCtrl.text) ?? weight;
                  calorieGoal = int.tryParse(goalCtrl.text) ?? calorieGoal;
                });
                Navigator.pop(context);
                StudioToast.show(context, 'PROFILE SAVED', icon: LucideIcons.checkCircle2);
              },
              child: const Text('SAVE MASTERPIECE'),
            ),
            const SizedBox(height: 40),
          ]),
        ),
      ),
    );
  }

  void _showAvatarPicker() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: AppColors.deepSlate, borderRadius: BorderRadius.vertical(top: Radius.circular(48))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('CHANGE AVATAR', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: AppColors.studioIndigo, letterSpacing: 1.2)),
          const SizedBox(height: 32),
          _buildActionItem(LucideIcons.camera, 'Take New Photo', () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
          _buildActionItem(LucideIcons.image, 'Choose from Gallery', () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
          _buildActionItem(LucideIcons.trash2, 'Remove Current', () { Navigator.pop(context); _removeAvatar(); }, isDanger: true),
          const SizedBox(height: 16),
        ]),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.85, padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: AppColors.deepSlate, borderRadius: BorderRadius.vertical(top: Radius.circular(48))),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('PRIVACY & DATA POLICY', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.studioIndigo)),
          const SizedBox(height: 32),
          _buildDocSection('Data Encryption', 'All your nutritional logs and physical data are encrypted using industry-standard protocols.'),
          _buildDocSection('AI Usage', 'Meal photos are analyzed locally or via secured cloud endpoints to estimate volume.'),
          const SizedBox(height: 40),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('I UNDERSTAND')),
        ])),
      ),
    );
  }

  void _showFaqDocs() {
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8, padding: const EdgeInsets.all(32),
        decoration: const BoxDecoration(color: AppColors.deepSlate, borderRadius: BorderRadius.vertical(top: Radius.circular(48))),
        child: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('STUDIO DOCUMENTATION', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14, color: AppColors.studioIndigo)),
          const SizedBox(height: 32),
          _buildDocSection('About Developer', 'Developed by Jri as an artistic take on automated nutrition tracking.'),
          _buildDocSection('Accuracy', 'AI regression models have ±10-15% variance based on lighting.'),
          const SizedBox(height: 40),
        ])),
      ),
    );
  }

  void _showLogoutConfirmation() {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(40),
        decoration: const BoxDecoration(color: AppColors.deepSlate, borderRadius: BorderRadius.vertical(top: Radius.circular(48))),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(LucideIcons.logOut, color: AppColors.deepRose, size: 48),
          const SizedBox(height: 24),
          const Text('CLOSE STUDIO?', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
          const SizedBox(height: 40),
          Row(children: [
            Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL'))),
            const SizedBox(width: 16),
            Expanded(child: ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: AppColors.deepRose), onPressed: () { Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const AuthScreen()), (route) => false); }, child: const Text('LOGOUT'))),
          ]),
        ]),
      ),
    );
  }

  // --- UI BUILDING BLOCKS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28.0),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _stagger(0, _buildProfileHeader()),
            const SizedBox(height: 32),
            _stagger(1, _buildPhysicalMatrix()),
            const SizedBox(height: 32),
            _stagger(2, Text('GOAL CANVAS', style: _sectionStyle)),
            const SizedBox(height: 16),
            _stagger(3, _buildGoalsCard()),
            const SizedBox(height: 32),
            _stagger(4, Text('STUDIO SETTINGS', style: _sectionStyle)),
            const SizedBox(height: 16),
            _stagger(5, _buildAccountRevealItem()),
            _stagger(6, _buildToggleItem(LucideIcons.bell, 'Notifications', 'App reminders & alerts', _notifEnabled, (v) => setState(() => _notifEnabled = v))),
            _stagger(7, _buildToggleItem(LucideIcons.moon, 'Studio Theme', 'Switch between Dark/Light', _isDarkMode, (v) => setState(() => _isDarkMode = v))),
            _stagger(8, _buildSettingItem(LucideIcons.shieldCheck, 'Privacy & Data', 'Encryption & Usage Policy', _showPrivacyPolicy)),
            _stagger(9, _buildSettingItem(LucideIcons.helpCircle, 'Studio FAQ & Docs', 'AI Model, Accuracy, About', _showFaqDocs)),
            const SizedBox(height: 40),
            _stagger(10, _buildLogoutBtn()),
            const SizedBox(height: 120),
          ]),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(children: [
      _buildOrganicAvatar(),
      const SizedBox(width: 24),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(userName, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 4),
        const Text('ELITE CREATOR', style: TextStyle(color: AppColors.studioIndigo, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      ])),
      GestureDetector(
        onTap: _showEditProfile,
        child: Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(12)), child: const Icon(LucideIcons.edit3, size: 18, color: AppColors.studioIndigo)),
      ),
    ]);
  }

  Widget _buildOrganicAvatar() {
    return Container(
      height: 80, width: 80,
      decoration: const BoxDecoration(
        gradient: AppColors.paintGradient,
        borderRadius: BorderRadius.only(topLeft: Radius.circular(35), topRight: Radius.circular(20), bottomLeft: Radius.circular(15), bottomRight: Radius.circular(45)),
      ),
      padding: const EdgeInsets.all(2),
      child: Container(
        decoration: const BoxDecoration(color: AppColors.deepSlate, borderRadius: BorderRadius.only(topLeft: Radius.circular(33), topRight: Radius.circular(18), bottomLeft: Radius.circular(13), bottomRight: Radius.circular(43))),
        clipBehavior: Clip.antiAlias,
        child: _localImagePath != null 
            ? Image.file(_localImagePath!, fit: BoxFit.cover)
            : profileImageUrl != null 
                ? Image.network(profileImageUrl!, fit: BoxFit.cover) 
                : const Center(child: Icon(LucideIcons.user, color: Colors.white24, size: 32)),
      ),
    );
  }

  Widget _buildPhysicalMatrix() {
    return Row(children: [
      Expanded(child: _buildInfoCard('Height', height.toString(), 'cm')),
      const SizedBox(width: 16),
      Expanded(child: _buildInfoCard('Weight', weight.toString(), 'kg')),
    ]);
  }

  Widget _buildInfoCard(String label, String value, String unit) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: AppColors.slateCard, borderRadius: BorderRadius.circular(32)),
      child: Column(children: [
        Text(label.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.slateMuted)),
        const SizedBox(height: 8),
        RichText(text: TextSpan(text: value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.white), children: [TextSpan(text: ' $unit', style: const TextStyle(fontSize: 12, color: AppColors.studioIndigo))])),
      ]),
    );
  }

  Widget _buildGoalsCard() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppColors.slateCard, borderRadius: BorderRadius.circular(40), border: Border.all(color: Colors.white.withValues(alpha: 0.05))),
      child: Column(children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          const Text('CALORIE TARGET', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text('$calorieGoal KCAL', style: TextStyle(color: AppColors.studioIndigo, fontWeight: FontWeight.w900, fontSize: 12)),
        ]),
        const SizedBox(height: 16),
        ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: 0.5, minHeight: 4, backgroundColor: Colors.white.withValues(alpha: 0.05), valueColor: AlwaysStoppedAnimation<Color>(AppColors.studioIndigo))),
      ]),
    );
  }

  Widget _buildAccountRevealItem() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart,
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.slateCard.withValues(alpha: _isAccountExpanded ? 0.8 : 0.5), borderRadius: BorderRadius.circular(32), border: Border.all(color: _isAccountExpanded ? AppColors.studioIndigo.withValues(alpha: 0.3) : Colors.transparent)),
      child: Column(children: [
        GestureDetector(
          onTap: () => setState(() => _isAccountExpanded = !_isAccountExpanded), behavior: HitTestBehavior.opaque,
          child: Row(children: [
            const Icon(LucideIcons.user, color: AppColors.slateMuted, size: 20),
            const SizedBox(width: 20),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Account Management', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text('Sync, Email, Password', style: TextStyle(color: AppColors.slateMuted, fontSize: 11))])),
            AnimatedRotation(turns: _isAccountExpanded ? 0.25 : 0, duration: const Duration(milliseconds: 300), child: const Icon(LucideIcons.chevronRight, color: AppColors.slateMuted, size: 16)),
          ]),
        ),
        ClipRect(child: AnimatedAlign(alignment: Alignment.topCenter, duration: const Duration(milliseconds: 500), curve: Curves.easeInOutQuart, heightFactor: _isAccountExpanded ? 1.0 : 0.0, child: Padding(padding: const EdgeInsets.only(top: 24), child: Column(children: [
          _buildInnerField('STUDIO EMAIL', _emailController),
          const SizedBox(height: 16),
          _buildInnerField('PHONE NUMBER', _phoneController),
          const SizedBox(height: 16),
          _buildInnerField('ACCESS KEY', _passController, isPass: true),
          const SizedBox(height: 32),
          ElevatedButton(onPressed: () { setState(() => _isAccountExpanded = false); StudioToast.show(context, 'ACCOUNT UPDATED', icon: LucideIcons.checkCircle2); }, style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)), child: const Text('UPDATE ACCOUNT', style: TextStyle(fontSize: 12))),
        ])))),
      ]),
    );
  }

  Widget _buildToggleItem(IconData icon, String title, String subtitle, bool val, Function(bool) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: AppColors.slateCard.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        Icon(icon, color: AppColors.slateMuted, size: 20),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(subtitle, style: const TextStyle(color: AppColors.slateMuted, fontSize: 11))])),
        Switch(value: val, onChanged: onChanged, activeThumbColor: AppColors.studioIndigo, activeTrackColor: AppColors.studioIndigo.withValues(alpha: 0.2)),
      ]),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppColors.slateCard.withValues(alpha: 0.5), borderRadius: BorderRadius.circular(24)), child: Row(children: [
        Icon(icon, color: AppColors.slateMuted, size: 20),
        const SizedBox(width: 20),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), Text(subtitle, style: const TextStyle(color: AppColors.slateMuted, fontSize: 11))])),
        const Icon(LucideIcons.chevronRight, color: AppColors.slateMuted, size: 16),
      ])),
    );
  }

  Widget _buildLogoutBtn() {
    return GestureDetector(
      onTap: _showLogoutConfirmation,
      child: Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), decoration: BoxDecoration(color: AppColors.deepRose.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(24), border: Border.all(color: AppColors.deepRose.withValues(alpha: 0.2))), child: const Center(child: Text('CLOSE STUDIO (LOGOUT)', style: TextStyle(color: AppColors.deepRose, fontWeight: FontWeight.w900, fontSize: 12, letterSpacing: 1.2)))),
    );
  }

  Widget _buildActionItem(IconData icon, String label, VoidCallback onTap, {bool isDanger = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(margin: const EdgeInsets.only(bottom: 12), padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(24)), child: Row(children: [
        Icon(icon, color: isDanger ? AppColors.deepRose : AppColors.slateMuted, size: 20),
        const SizedBox(width: 16),
        Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: isDanger ? AppColors.deepRose : Colors.white)),
      ])),
    );
  }

  Widget _buildInnerField(String label, TextEditingController controller, {bool isPass = false, bool isNum = false}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.slateMuted, letterSpacing: 1)),
      const SizedBox(height: 8),
      TextField(controller: controller, obscureText: isPass, keyboardType: isNum ? TextInputType.number : TextInputType.text, style: const TextStyle(fontSize: 13), decoration: InputDecoration(isDense: true, filled: true, fillColor: Colors.black12, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
    ]);
  }

  Widget _buildDocSection(String title, String content) {
    return Padding(padding: const EdgeInsets.only(bottom: 24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12, color: Colors.white)),
      const SizedBox(height: 8),
      Text(content, style: const TextStyle(fontSize: 13, color: AppColors.slateMuted, height: 1.6)),
    ]));
  }

  TextStyle get _sectionStyle => const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: AppColors.slateMuted);
}
