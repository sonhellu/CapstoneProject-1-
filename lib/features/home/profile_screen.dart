import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hi_cam_app/l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(t.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _Tile(
            icon: Icons.person,
            title: 'Personal Info',
            onTap: () => context.go('/profile/info'),
          ),
          _Tile(
            icon: Icons.verified_user,
            title: 'Verify Identity',
            onTap: () => context.go('/profile/verify'),
          ),
          const Divider(height: 32),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.redAccent),
            title: Text(t.logout, style: const TextStyle(color: Colors.redAccent)),
            onTap: () => context.go('/sign-in'),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  const _Tile({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class PersonalInfoScreen extends StatelessWidget {
  const PersonalInfoScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Personal Info')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.person, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              'Your Verification Information',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _ReadOnlyField(label: 'University', value: 'Seoul National University'),
            const SizedBox(height: 16),
            _ReadOnlyField(label: 'Department', value: 'Computer Science'),
            const SizedBox(height: 16),
            _ReadOnlyField(label: 'Academic Year', value: '2024'),
            const SizedBox(height: 16),
            _ReadOnlyField(label: 'Nationality', value: 'South Korea'),
            const SizedBox(height: 16),
            _ReadOnlyField(label: 'University Email', value: 'student@snu.ac.kr'),
            const SizedBox(height: 32),
            SizedBox(
              height: 52,
              child: OutlinedButton(
                onPressed: () => context.go('/profile/verify'),
                child: const Text('Update Information'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VerifyIdentityScreen extends StatefulWidget {
  const VerifyIdentityScreen({super.key});

  @override
  State<VerifyIdentityScreen> createState() => _VerifyIdentityScreenState();
}

class _VerifyIdentityScreenState extends State<VerifyIdentityScreen> with TickerProviderStateMixin {
  String? selectedUniversity;
  String? selectedDepartment;
  String? selectedYear;
  String? selectedNationality;
  String? universityEmail;
  bool isSubmitted = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  final TextEditingController _emailController = TextEditingController();

  final List<String> universities = [
    'Seoul National University',
    'Yonsei University',
    'Korea University',
    'KAIST',
    'POSTECH',
    'Hanyang University',
    'Sungkyunkwan University',
    'Other'
  ];

  final List<String> departments = [
    'Computer Science',
    'Engineering',
    'Business',
    'Medicine',
    'Law',
    'Arts',
    'Sciences',
    'Other'
  ];

  final List<String> academicYears = [
    '2024',
    '2023',
    '2022',
    '2021',
    '2020',
    '2019',
    '2018',
    '2017'
  ];

  final List<String> nationalities = [
    'South Korea',
    'United States',
    'China',
    'Japan',
    'Vietnam',
    'Thailand',
    'Indonesia',
    'Philippines',
    'Malaysia',
    'Singapore',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify Identity')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: isSubmitted ? _buildSubmittedView() : _buildFormView(),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _AnimatedDropdownField(
          label: 'University',
          value: selectedUniversity,
          items: universities,
          onChanged: (value) => setState(() => selectedUniversity = value),
        ),
        const SizedBox(height: 16),
        _AnimatedDropdownField(
          label: 'Department',
          value: selectedDepartment,
          items: departments,
          onChanged: (value) => setState(() => selectedDepartment = value),
        ),
        const SizedBox(height: 16),
        _AnimatedDropdownField(
          label: 'Academic Year',
          value: selectedYear,
          items: academicYears,
          onChanged: (value) => setState(() => selectedYear = value),
        ),
        const SizedBox(height: 16),
        _AnimatedDropdownField(
          label: 'Nationality',
          value: selectedNationality,
          items: nationalities,
          onChanged: (value) => setState(() => selectedNationality = value),
        ),
        const SizedBox(height: 16),
        _AnimatedEmailField(
          label: 'University Email',
          hintText: 'student@university.edu',
          controller: _emailController,
          onChanged: (value) => setState(() => universityEmail = value),
        ),
        const SizedBox(height: 32),
        SizedBox(
          height: 52,
          child: ElevatedButton(
            onPressed: () {
              if (selectedUniversity != null &&
                  selectedDepartment != null &&
                  selectedYear != null &&
                  selectedNationality != null &&
                  universityEmail != null &&
                  universityEmail!.isNotEmpty) {
                setState(() => isSubmitted = true);
                _animationController.forward();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Verification submitted!')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please fill all fields')),
                );
              }
            },
            child: const Text('Submit Verification'),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmittedView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          Text(
            'Verification Submitted Successfully!',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _ReadOnlyField(label: 'University', value: selectedUniversity!),
          const SizedBox(height: 16),
          _ReadOnlyField(label: 'Department', value: selectedDepartment!),
          const SizedBox(height: 16),
          _ReadOnlyField(label: 'Academic Year', value: selectedYear!),
          const SizedBox(height: 16),
          _ReadOnlyField(label: 'Nationality', value: selectedNationality!),
          const SizedBox(height: 16),
          _ReadOnlyField(label: 'University Email', value: universityEmail!),
          const SizedBox(height: 32),
          SizedBox(
            height: 52,
            child: OutlinedButton(
              onPressed: () {
                setState(() {
                  isSubmitted = false;
                  selectedUniversity = null;
                  selectedDepartment = null;
                  selectedYear = null;
                  selectedNationality = null;
                  universityEmail = null;
                  _emailController.clear();
                });
                _animationController.reset();
              },
              child: const Text('Edit Information'),
            ),
          ),
        ],
      ),
    );
  }
}

class _AnimatedEmailField extends StatefulWidget {
  final String label;
  final String hintText;
  final TextEditingController controller;
  final ValueChanged<String?> onChanged;

  const _AnimatedEmailField({
    required this.label,
    required this.hintText,
    required this.controller,
    required this.onChanged,
  });

  @override
  State<_AnimatedEmailField> createState() => _AnimatedEmailFieldState();
}

class _AnimatedEmailFieldState extends State<_AnimatedEmailField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.label, style: Theme.of(context).textTheme.labelLarge),
              const SizedBox(height: 8),
              TextFormField(
                controller: widget.controller,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Email required';
                  if (!RegExp(r'^[^@\s]+@stu\.[^@\s]+$').hasMatch(value)) {
                    return 'Must be university email (@stu.domain)';
                  }
                  return null;
                },
                onChanged: (value) {
                  _controller.forward().then((_) => _controller.reverse());
                  widget.onChanged(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AnimatedDropdownField extends StatefulWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _AnimatedDropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_AnimatedDropdownField> createState() => _AnimatedDropdownFieldState();
}

class _AnimatedDropdownFieldState extends State<_AnimatedDropdownField> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: _DropdownField(
            label: widget.label,
            value: widget.value,
            items: widget.items,
            onChanged: (value) {
              _controller.forward().then((_) => _controller.reverse());
              widget.onChanged(value);
            },
          ),
        );
      },
    );
  }
}

class _ReadOnlyField extends StatelessWidget {
  final String label;
  final String value;

  const _ReadOnlyField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).dividerColor),
            borderRadius: BorderRadius.circular(12),
            color: Theme.of(context).colorScheme.surface,
          ),
          child: Row(
            children: [
              Expanded(child: Text(value)),
              Icon(Icons.lock, size: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6)),
            ],
          ),
        ),
      ],
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          items: items.map((item) => DropdownMenuItem(
            value: item,
            child: Text(item),
          )).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}


