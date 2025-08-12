
import 'package:pristine_andaman/utils/new_utils/ui.dart';
import 'package:flutter/material.dart';
import 'package:pristine_andaman/utils/constant.dart';



class SlideToast extends StatefulWidget{
  final Function onRemove;
  final String message;
  final String title;
  final Color color;
  const SlideToast({required this.title, required this.message, required this.color,required this.onRemove});

  @override
  SlideToastState createState() => SlideToastState();
}

class SlideToastState extends State<SlideToast>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool close = false;
  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration:const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = Tween<double>(begin: 100, end: 0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.fastOutSlowIn),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 2), () {
      if(!close){
        _controller.reverse();
        _controller.addStatusListener((status) {
          if (status == AnimationStatus.dismissed) {
            widget.onRemove();
          }
        });
      }

    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _animation.value),
          child: Material(
            color: Colors.transparent,
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Container(
                width: getWidth(350),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.title!=""?Text(
                            widget.title,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Colors.white
                            ),
                          ):const SizedBox(),
                          Text(
                            widget.message,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(
                                color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(onPressed: (){
                      close = true;
                      _controller.reverse();
                      _controller.addStatusListener((status) {
                        if (status == AnimationStatus.dismissed) {
                          widget.onRemove();
                        }
                      });
                    }, icon:const Icon(
                      Icons.close,
                    color: Colors.white,
                    //  color: Theme.of(context).primaryColor,
                      size: 20,
                    ))
                  ],
                ),
              ),
            ),
          )
        );
      },
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
