import 'package:flutter/material.dart';

class ImageWithRetry extends StatefulWidget {
  final String imageUrl;
  final int maxRetries;

  const ImageWithRetry(
      {super.key, required this.imageUrl, this.maxRetries = 3});

  @override
  ImageWithRetryState createState() => ImageWithRetryState();
}

class ImageWithRetryState extends State<ImageWithRetry> {
  late Future<NetworkImage> _imageFuture;
  bool _isLoading = true;
  bool _isError = false;
  int _retryCount = 0;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  void _loadImage() async {
    setState(() {
      _isLoading = true;
      _isError = false;
    });

    try {
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isError = true;
      });

      if (_retryCount < widget.maxRetries) {
        _retryCount++;
        Future.delayed(const Duration(seconds: 1), () => _loadImage());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: _isError ? _loadImage : null,
      child: Stack(
        children: [
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          if (!_isLoading && !_isError)
            Image.network(
              widget.imageUrl,
              loadingBuilder: (context, child, loadingProgress) {
                return loadingProgress == null
                    ? child
                    : Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
              },
              errorBuilder: (context, error, stackTrace) {
                _isError = true;
                return const Center(
                  child: Icon(Icons.broken_image),
                );
              },
            ),
          if (_isError)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image),
                  SizedBox(height: 8),
                  Text('加载失败，请点击重试'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
