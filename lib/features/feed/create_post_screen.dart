import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../viewmodels/feed_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../core/theme/app_theme.dart';

class CreatePostScreen extends StatefulWidget {
  final bool openCamera;
  const CreatePostScreen({super.key, this.openCamera = false});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  String _selectedLocation = 'Hà Nội';
  final List<String> _locations = ['Hà Nội', 'Sài Gòn', 'Đà Nẵng', 'Huế', 'Đà Lạt', 'Cần Thơ', 'Hải Phòng', 'Vũng Tàu'];
  XFile? _pickedFile;
  final ImagePicker _picker = ImagePicker();
  bool _isPosting = false;

  @override
  void initState() {
    super.initState();
    if (widget.openCamera) {
      _pickImage(ImageSource.camera);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? file = await _picker.pickImage(
        source: source,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );
      if (file != null) {
        setState(() {
          _pickedFile = file;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi chọn ảnh: $e')),
      );
    }
  }

  void _handlePost() async {
    if (_pickedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn hoặc chụp một tấm ảnh!')),
      );
      return;
    }

    setState(() => _isPosting = true);
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    final feedVm = context.read<FeedViewModel>();
    final profileVm = context.read<ProfileViewModel>();

    feedVm.addNewPost(_captionController.text, _pickedFile!.path, location: _selectedLocation);
    profileVm.syncUserPostsCount(feedVm.userPostsCount);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã đăng bài thành công!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Bài đăng mới', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isPosting ? null : _handlePost,
            child: _isPosting 
              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryOrange))
              : const Text('Đăng', style: TextStyle(color: AppTheme.primaryOrange, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: const [
                  CircleAvatar(
                    backgroundImage: CachedNetworkImageProvider('https://images.pexels.com/users/avatars/1640777/pexels-user-1640777.jpeg?auto=compress&cs=tinysrgb&w=200'),
                  ),
                  SizedBox(width: 12),
                  Text('Bạn (Foodie)', style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Chụp ảnh'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.camera);
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.photo_library),
                        title: const Text('Chọn từ thư viện'),
                        onTap: () {
                          Navigator.pop(context);
                          _pickImage(ImageSource.gallery);
                        },
                      ),
                    ],
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 300,
                color: AppTheme.backgroundLight,
                child: _pickedFile != null
                    ? (kIsWeb 
                        ? Image.network(_pickedFile!.path, fit: BoxFit.cover)
                        : Image.file(File(_pickedFile!.path), fit: BoxFit.cover))
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.add_a_photo_outlined, size: 50, color: Colors.grey),
                          SizedBox(height: 12),
                          Text('Nhấn để chọn ảnh', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: AppTheme.primaryOrange),
                  const SizedBox(width: 12),
                  const Text('Vị trí:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedLocation,
                      isExpanded: true,
                      underline: const SizedBox(),
                      items: _locations.map((loc) {
                        return DropdownMenuItem(value: loc, child: Text(loc));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLocation = val);
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Divider(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _captionController,
                maxLines: 5,
                decoration: const InputDecoration(
                  hintText: 'Bạn đang nghĩ gì về món ăn này?',
                  border: InputBorder.none,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
