import 'package:flutter/material.dart';
import 'success_screen.dart'; // Import for navigation
import 'package:flutter/services.dart';

// Signup Screen w/ Interactive Form
class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final List<String> _avatars = ['🐱','🐶','🦊','🐸'];
  int _selected = 0;
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  double _pwdStrength = 0.0;
  Color _pwdColor = Colors.red;
  String _pwdLabel = 'Weak';

  // Adventure Progress Tracker
  double _progress = 0.0;
  Color _progressColor = Colors.red;
  String _milestoneMsg = '';
  double _celebrateScale = 0.0;
  int _lastMilestone = 0;

  @override
  void initState() {                                    
    super.initState();                                  
    // Watch fields to update progress in real time      
    _nameController.addListener(_recomputeProgress);    
    _emailController.addListener(_recomputeProgress);   
    _passwordController.addListener(_recomputeProgress);
    _dobController.addListener(_recomputeProgress);     
  }                                                     

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dobController.dispose();
    super.dispose();
  }

  // Bounce checkmark helper
  Widget _validCheck(bool isValid) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 200),
      tween: Tween(begin: 0, end: isValid ? 1 : 0),
      builder: (_, s, __) => Transform.scale(
        scale: 0.8 + 0.2 * s,
        child: Opacity(
          opacity: s,
          child: const Icon(Icons.check_circle, color: Colors.green),
        ),
      ),
    );
  }

  // simple strength calculator
  void _onPasswordChanged(String v) {         
    int score = 0;                            
    if (v.length >= 6) score++;               
    if (v.length >= 10) score++;              
    if (RegExp(r'[A-Z]').hasMatch(v)) score++;
    if (RegExp(r'[0-9]').hasMatch(v)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(v)) score++;
                                               
    double s = score / 5.0;                   
    Color c;                                  
    String label;                             
    if (score <= 1) { c = Colors.red; label = 'Weak'; }              
    else if (score == 2) { c = Colors.orange; label = 'Fair'; }      
    else if (score == 3) { c = Colors.amber; label = 'Okay'; }       
    else if (score == 4) { c = Colors.lightGreen; label = 'Good'; }  
    else { c = Colors.green; label = 'Strong'; }                     

    setState(() {                                
      _pwdStrength = s;                          
      _pwdColor = c;                             
      _pwdLabel = label;                         
    });   
    _recomputeProgress();                                       
  }

  void _recomputeProgress() {                            
    int filled = 0;                                      
    if (_nameController.text.trim().isNotEmpty) filled++;
    if (_emailController.text.trim().isNotEmpty) filled++;
    if (_passwordController.text.isNotEmpty) filled++;   
    if (_dobController.text.trim().isNotEmpty) filled++; 

    final newProgress = filled / 4.0;                    
    final newColor = Color.lerp(Colors.red, Colors.green, newProgress)!; 

    // Determine current milestone                            
    int m = 0;                                               
    if (newProgress >= 1.0) m = 100;                         
    else if (newProgress >= 0.75) m = 75;                    
    else if (newProgress >= 0.50) m = 50;                    
    else if (newProgress >= 0.25) m = 25;                    

    String msg = '';                                         
    if (m > _lastMilestone) {                                
      if (m == 25) msg = 'Nice start! 25% complete 🎯';      
      if (m == 50) msg = 'Halfway there! 50% 🚀';            
      if (m == 75) msg = 'So close! 75% 🔥';                 
      if (m == 100) msg = 'All done! 100% 🎉';               
      _triggerCelebrate();                                    
    }                                                         

    setState(() {                                             
      _progress = newProgress;                                
      _progressColor = newColor;                              
      _milestoneMsg = msg;                                    
      _lastMilestone = m;                                     
    });                                                       
  }                                                           

  // Tiny celebratory animation 
  void _triggerCelebrate() async {    
    HapticFeedback.mediumImpact();                         
    setState(() => _celebrateScale = 1.0);                     
    await Future.delayed(const Duration(milliseconds: 700));   
    if (mounted) setState(() => _celebrateScale = 0.0);        
  }                                                            

  // badge rules creator
  List<String> _computeBadges() {
    final List<String> badges = [];
    // Strong Password achievment
    if (_pwdLabel == 'Strong' || _pwdStrength >= 0.8) {
      badges.add('🏆 Strong Password Master');
    }
    // Sign up before 12 PM achievment
    final now = DateTime.now();
    if (now.hour < 12) {
      badges.add('⏰ The Early Bird Special');
    }
    // Profile Completer achievment
    if (_nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _dobController.text.trim().isNotEmpty) {
      badges.add('✅ Profile Completer');
    }
    return badges;
  }                                              

  // Date Picker Function
  Future<void> _selectDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
      _recomputeProgress(); 
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      Future.delayed(const Duration(seconds: 2), () {
        if (!mounted) return; // Check if the widget is still in the tree
        setState(() {
          _isLoading = false;
        });
        final badges = _computeBadges();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SuccessScreen(userName: _nameController.text,
            avatarEmoji: _avatars[_selected], badges: badges,),
          ),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your Account 🎉'),
        backgroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Progress Bar (top of form)
                ClipRRect(                                           
                  borderRadius: BorderRadius.circular(8),            
                  child: LinearProgressIndicator(                    
                    minHeight: 12,                                   
                    value: _progress,                                
                    backgroundColor: Colors.grey[300],               
                    valueColor: AlwaysStoppedAnimation(_progressColor), 
                  ),
                ),                                                   
                const SizedBox(height: 8),                           
                Row(                                                 
                  children: [                                        
                    const Text('Adventure Progress'),                
                    const Spacer(),                                  
                    Text('${(_progress * 100).round()}%'),           
                  ],                                                 
                ),                                                   
                const SizedBox(height: 8),                           
                Stack(                                               
                  alignment: Alignment.centerRight,                  
                  children: [                                        
                    if (_milestoneMsg.isNotEmpty)                    
                      Align(                                         
                        alignment: Alignment.centerLeft,             
                        child: Text(                                 
                          _milestoneMsg,                             
                          style: const TextStyle(                    
                            fontWeight: FontWeight.w600,             
                            color: Colors.deepPurple,                
                          ),                                         
                        ),                                           
                      ),                                             
                    AnimatedScale(                                   
                      scale: _celebrateScale,                        
                      duration: const Duration(milliseconds: 250),   
                      child: const Icon(Icons.emoji_events,          
                          color: Colors.amber, size: 28),            
                    ),                                               
                  ],                                                 
                ),                                                   

                const SizedBox(height: 16),                          

                // Animated Form Header
                AnimatedContainer(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.tips_and_updates,
                          color: Colors.deepPurple[800]),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Complete your adventure profile!',
                          style: TextStyle(
                            color: Colors.deepPurple[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),

                // Name Field
                _buildTextField(
                  controller: _nameController,
                  label: 'Adventure Name',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'What should we call you on this adventure?';
                    }
                    return null;
                  },
                  isValid: (v) => v.trim().isNotEmpty,
                ),
                const SizedBox(height: 20),

                // Email Field
                _buildTextField(
                  controller: _emailController,
                  label: 'Email Address',
                  icon: Icons.email,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'We need your email for adventure updates!';
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return 'Oops! That doesn\'t look like a valid email';
                    }
                    return null;
                  },
                  isValid: (v) => v.contains('@') && v.contains('.'),
                ),
                const SizedBox(height: 20),

                // DOB w/Calendar
                TextFormField(
                  controller: _dobController,
                  readOnly: true,
                  onTap: _selectDate,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    prefixIcon:
                        const Icon(Icons.calendar_today, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.date_range),
                          onPressed: _selectDate,
                        ),
                        _validCheck(_dobController.text.isNotEmpty),
                      ],
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'When did your adventure begin?';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // Pswd Field w/ Toggle
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  onChanged: (v) {
                    _onPasswordChanged(v);
                    setState(() {});
                  },
                  decoration: InputDecoration(
                    labelText: 'Secret Password',
                    prefixIcon:
                        const Icon(Icons.lock, color: Colors.deepPurple),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                      icon: Icon(
                        _isPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.deepPurple,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                    _validCheck(_passwordController.text.length >= 6),
                    ],
                  ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Every adventurer needs a secret password!';
                    }
                    if (value.length < 6) {
                      return 'Make it stronger! At least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 30),

                const SizedBox(height: 10),
                // linear strength meter + label
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: _pwdStrength, // 0..1
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(_pwdColor),
                  ),
                ),
                const SizedBox(height: 6),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    _pwdLabel,
                    style: TextStyle(color: _pwdColor, fontWeight: FontWeight.w600),
                  ),
                ),

                const SizedBox(height: 30),

                // Avatar Picker
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Choose an avatar:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  children: List.generate(_avatars.length, (i) {
                    final isSelected = i == _selected;
                    return GestureDetector(
                      onTap: () => setState(() => _selected = i),
                      child: CircleAvatar(
                        radius: isSelected ? 26 : 24,
                        backgroundColor: isSelected
                            ? Colors.deepPurple.shade100
                            : Colors.grey.shade200,
                        child: Text(_avatars[i], style: const TextStyle(fontSize: 24)),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),

                // Submit Button w/ Loading Animation
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _isLoading ? 60 : double.infinity,
                  height: 60,
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.deepPurple),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            elevation: 5,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Start My Adventure',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                              SizedBox(width: 10),
                              Icon(Icons.rocket_launch, color: Colors.white),
                            ],
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    bool Function(String)? isValid,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.deepPurple),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        suffixIcon: (isValid == null)
            ? null
            : _validCheck(isValid(controller.text)),
      ),
      validator: validator,
    );
  }
}