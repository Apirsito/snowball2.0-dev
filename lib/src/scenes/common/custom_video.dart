import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CustomVideo extends StatefulWidget {
  final String title;
  final String urlVideo;
  final File fileVideo;
  final bool isUpload;
  CustomVideo({
    this.title = 'Chewie Demo',
    this.urlVideo,
    this.isUpload,
    this.fileVideo,
  });

  @override
  State<StatefulWidget> createState() {
    return _CustomVideoState();
  }
}

class _CustomVideoState extends State<CustomVideo> {
  VideoPlayerController _videoPlayerController;
  ChewieController _chewieController;


  @override
  Widget build(BuildContext context) {
        return _videoPlayerController.value.initialized
            ? SizedBox(
                height: identifySize(),
                child: Chewie(controller: _chewieController),
              )
            : AspectRatio(
                aspectRatio: _videoPlayerController.value.aspectRatio,
                child: Stack(
                  alignment: Alignment.bottomCenter,
                  children: <Widget>[
                    VideoPlayer(_videoPlayerController),
                    _PlayPauseOverlay(controller: _videoPlayerController),
                    VideoProgressIndicator(
                      _videoPlayerController,
                      allowScrubbing: true,
                    ),
                  ],
                ),
              );
  }

  @override
  void dispose() {
    _videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  double identifySize() {
    final sizevideo = _chewieController.videoPlayerController.value.size;
    if (sizevideo.height > 1280 || sizevideo.height >= sizevideo.width)
      return MediaQuery.of(context).size.height / 2;
    else if (sizevideo.height == 1280)
      return sizevideo.flipped.aspectRatio * 405;
    else
      return sizevideo.flipped.aspectRatio * 485;
  }

  @override
  void initState() {
    super.initState();
    if (widget.isUpload != null && widget.isUpload) {
      if (mounted) setState(() {}); // <<<
      _videoPlayerController = VideoPlayerController.file(widget.fileVideo);
    } else {
      if (mounted) setState(() {}); // <<<
      try{

      _videoPlayerController = VideoPlayerController.network(widget.urlVideo);
      }catch(a){
        print(a);
      }
    }

 initVideoPlayer();

//    _chewieController = ChewieController(
//      videoPlayerController: _videoPlayerController,
//      aspectRatio: _videoPlayerController.value.aspectRatio,
//      looping: true,
//      allowedScreenSleep: false,
//      placeholder: Container(
//        color: Colors.grey,
//      ),
//    );
  }

  Future<void> initVideoPlayer() async {
    try {
      await _videoPlayerController.initialize();
      setState(() {
        _chewieController = ChewieController(
          videoPlayerController: _videoPlayerController,
          aspectRatio: _videoPlayerController.value.aspectRatio,
          autoPlay: false,
          looping: false,
          allowFullScreen: true,
          errorBuilder: (context, errorMessage) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Text(
                  errorMessage,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            );
          },
        );
      });
    } catch (e) {
      print("error $e");
    }
  }
}

class _PlayPauseOverlay extends StatelessWidget {
  final VideoPlayerController controller;

  const _PlayPauseOverlay({Key key, this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {

return Stack(
children: <Widget>[
    controller.value.isPlaying
        ? SizedBox.shrink()
        : Container(
            color: Colors.black,
            child: Center(
              child: Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 100.0,
              ),
            ),
          ),
  GestureDetector(
    onTap: () {
      controller.value.isPlaying ? controller.pause() : controller.play();
    },
  ),
],
    );


  }
}
