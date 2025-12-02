import 'package:cleanswitch_staff/widgets/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cleanswitch_staff/models/task.dart';
import 'dart:io';

import 'package:cleanswitch_staff/widgets/task_details/full_image.dart';
import 'package:cleanswitch_staff/widgets/task_details/video_play.dart';

class TaskImageGrid extends StatefulWidget {
  final Task? task;
  final List<File> newImages;
  final List<File> newVideos;
  final Function(int)? onDeleteNewImage;
  final Function(int)? onDeleteExistingImage;
  final Function(File)? onNewVideoAdded;
  final Function(int)? onDeleteNewVideo;

  const TaskImageGrid({
    super.key,
    required this.task,
    required this.newImages,
    this.newVideos = const [],
    this.onDeleteNewImage,
    this.onDeleteExistingImage,
    this.onNewVideoAdded,
    this.onDeleteNewVideo,
  });

  @override
  State<TaskImageGrid> createState() => _TaskImageGridState();
}

class _TaskImageGridState extends State<TaskImageGrid> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _takeImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        widget.newImages.add(File(image.path));
      });
    }
  }

  Future<void> _takeVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);
    if (video != null) {
      final videoFile = File(video.path);
      widget.onNewVideoAdded?.call(videoFile);
    }
  }

  void _showMediaOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () {
                  Navigator.pop(context);
                  _takeImage();
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Take Video'),
                onTap: () {
                  Navigator.pop(context);
                  _takeVideo();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  bool _isVideo(String url) {
    return url.toLowerCase().endsWith('.mp4') || 
           url.toLowerCase().endsWith('.mov') ||
           url.toLowerCase().endsWith('.webm');
  }

  Widget _buildMediaThumbnail(String mediaUrl, int index, bool isNew) {
    final isVideo = _isVideo(mediaUrl);
    final isNetworkImage = mediaUrl.startsWith('http');

    return Stack(
      children: [
        // Clickable area for viewing media (images/videos)
        GestureDetector(
          onTap: () {
            if (isVideo) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VideoPlayerScreen(videoPath: mediaUrl),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => FullImageView(imagePath: mediaUrl),
                ),
              );
            }
          },
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              color: Colors.grey[200],
              child: isVideo
                  ? Container(
                      alignment: Alignment.center,
                      child: const Icon(Icons.videocam, size: 40, color: Colors.grey),
                    )
                  : isNetworkImage
                      ? Image.network(
                          mediaUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.broken_image, size: 40),
                        )
                      : Image.file(
                          File(mediaUrl),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
            ),
          ),
        ),

        // Delete button (positioned in top-right corner)
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () {
              if (isNew) {
                // For new media, we need to find the correct index in the respective list
                final existingImagesCount = widget.task?.images.length ?? 0;
                
                if (isVideo) {
                  // This is a new video - find its index in newVideos list
                  final newImagesCount = widget.newImages.length;
                  final allMediaBeforeVideos = existingImagesCount + newImagesCount;
                  final videoIndex = index - allMediaBeforeVideos;
                  
                  if (videoIndex >= 0 && videoIndex < widget.newVideos.length) {
                    widget.onDeleteNewVideo?.call(videoIndex);
                  }
                } else {
                  // This is a new image - find its index in newImages list
                  final imageIndex = index - existingImagesCount;
                  if (imageIndex >= 0 && imageIndex < widget.newImages.length) {
                    widget.onDeleteNewImage?.call(imageIndex);
                  }
                }
              } else {
                // This is an existing image
                widget.onDeleteExistingImage?.call(index);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black54,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.close,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Video play icon overlay (for videos only)
        if (isVideo)
          const Positioned.fill(
            child: Align(
              alignment: Alignment.center,
              child: Icon(Icons.play_circle_fill, 
                  color: Colors.white70, size: 40),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final existingMedia = widget.task?.images.map((img) => img.image).toList() ?? [];
    final newImages = widget.newImages.map((file) => file.path).toList();
    final newVideos = widget.newVideos.map((file) => file.path).toList();
    
    final List<Map<String, dynamic>> allMedia = [
      ...existingMedia.map((media) => {'url': media, 'isNew': false, 'type': 'image'}),
      ...newImages.map((img) => {'url': img, 'isNew': true, 'type': 'image'}),
      ...newVideos.map((vid) => {'url': vid, 'isNew': true, 'type': 'video'}),
    ];

    return Column(
      children: [
        if (allMedia.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              'No media added yet',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: allMedia.length,
            itemBuilder: (context, index) {
              final media = allMedia[index];
              return _buildMediaThumbnail(
                media['url'] as String,
                index,
                media['isNew'] as bool,
              );
            },
          ),
        
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _showMediaOptions,
          child: Text('Add Media', style: TextStyle(color: AppColor.appBannerColor),),
        ),
      ],
    );
  }
}