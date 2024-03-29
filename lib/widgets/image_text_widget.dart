import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:dog_path_app/providers/dog_path_provider.dart';
import '../services/animate_widgets.dart';

class ImageTextWidget extends StatefulWidget {
  /// getting index from HomeScreenWidget from the parent Listview Builder
  ImageTextWidget({this.index});
  final int index;

  @override
  _ImageTextWidgetState createState() => _ImageTextWidgetState();
}

class _ImageTextWidgetState extends State<ImageTextWidget> {
  int _indexFromImage = 0;
  int _itemCount = 0;
  int _selectedIndex = 0;
  int previousImageSelectedIndex = 0;
  ScrollController _scrollImageController;
  ScrollController _scrollTextController;

  int _currentIndex =
      0; //IT WONT WAIT FOR FUTURE FUNCTION AND WILL ALSO HOLD SELECTED VALUE

  bool isFromText = false;
  bool isFromImage = false;

  ///FUNCTION TO ANIMATE LIST VIEW .i.e [Image] and [Text]
  Future<void> _animateList(
      int ind, double width, bool fromText, bool fromImage) async {
    ///if [Text] i.e Path is tapped
    ///
    final animateText =
        AnimateText(scrollTextController: _scrollTextController);
    final animateImage =
        AnimateImage(scrollImageController: _scrollImageController);

    if (fromText && !fromImage) {
      if (ind > _selectedIndex) {
        await animateText.animateForward(ind, width, _selectedIndex);
        await animateImage.animateForward(ind, width, _selectedIndex);
        _selectedIndex = ind;
      } else if (ind < _selectedIndex) {
        await animateText.animateBackward(ind, width, _selectedIndex);
        await animateImage.animateBackward(ind, width, _selectedIndex);
        _selectedIndex = ind;
      }

      isFromImage = false;
      isFromText = false;
    }

    ///When [Image] is scrolled
    ///
    ///
    else if (fromImage && !fromText) {
      if (previousImageSelectedIndex < _selectedIndex) {
        await animateImage.animateForward(
            previousImageSelectedIndex, width, _selectedIndex);
        await animateText.animateForward(
            _selectedIndex, width, previousImageSelectedIndex);
      } else if (previousImageSelectedIndex > _selectedIndex) {
        print("RAN from IMAGE BACKWARD");
        await animateImage.animateBackward(
            previousImageSelectedIndex, width, _selectedIndex);
        await animateText.animateBackward(
            _selectedIndex, width, previousImageSelectedIndex);
      }
      isFromText = false;
      isFromImage = false;
    } else
      return;
  }

  @override
  void initState() {
    super.initState();
    _scrollImageController = ScrollController();
    _scrollTextController = ScrollController();

    _scrollImageController.addListener(
        () => _scrollListenerWithItemCount(_itemCount, _indexFromImage));
    _scrollTextController.addListener(
        () => _scrollListenerWithItemCount(_itemCount, _indexFromImage));
  }

  @override
  void dispose() {
    super.dispose();
    _scrollImageController.removeListener(
        () => _scrollListenerWithItemCount(_itemCount, _indexFromImage));

    _scrollImageController.dispose();

    _scrollTextController.removeListener(
        () => _scrollListenerWithItemCount(_itemCount, _indexFromImage));
    _scrollTextController.dispose();
  }

  ///Live listener to the Image List view
  ///for getting current [index] of the [image]
  ///

  void _scrollListenerWithItemCount(int items, int ind) {
    bool isChanged;
    int currentImageIndex;
    final width = MediaQuery.of(context).size.width;

    /// Checking if the [image] animated form the Image List
    /// isFromText will [false] that means user swiped the [image]
    ///

    if (!isFromText) {
      isFromImage = true;
      int itemCount = items;
      double scrollOffset = _scrollImageController.position.pixels;
      double viewportHeight = _scrollImageController.position.viewportDimension;
      double scrollRange = _scrollImageController.position.maxScrollExtent -
          _scrollImageController.position.minScrollExtent;

      currentImageIndex =
          (scrollOffset / (scrollRange + viewportHeight) * itemCount).floor();
      previousImageSelectedIndex = _selectedIndex;
      _selectedIndex = currentImageIndex;

      isChanged = _selectedIndex != previousImageSelectedIndex ? true : false;

      ///if the [image] was actually moved

      if (isChanged) {
        isChanged = !isChanged;
        setState(() {
          _currentIndex = _selectedIndex;
          _animateList(ind, width, isFromText, isFromImage);
        });
      } else
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * .40;
    final width = MediaQuery.of(context).size.width;

    return Container(
      height: height,
      width: width,
      child: Column(
        children: [
          _buildImage(height, width),
          _buildText(height, width),
        ],
      ),
    );
  }

  ///Returns the [paths] in [Text] using [Listview]
  ///inside a [Container]
  ///

  Widget _buildText(double height, double width) {
    final dogP = Provider.of<DogPathProvider>(context, listen: false).dogPath;
    final subP = dogP[widget.index].subpaths;

    return Container(
      height: height * .20,
      width: width,
      padding: EdgeInsets.only(left: 20),
      color: Colors.black,
      child: ListView.builder(
        controller: _scrollTextController,
        scrollDirection: Axis.horizontal,
        itemCount: dogP[widget.index].subpaths.length,
        itemBuilder: (ctx, ind) {
          return Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    isFromText = true;
                    isFromImage = false;
                    print("selected Index from On TAP: $_selectedIndex");
                    _currentIndex = ind;
                    _animateList(ind, width, isFromText, isFromImage);
                  });
                },
                child: Text(
                  subP[ind].subTitle,
                  style: TextStyle(
                    color:
                        _currentIndex == ind ? Colors.white : Color(0xff778fab),
                    fontSize: 20,
                  ),
                ),
              ),
              SizedBox(width: 10),
              Opacity(
                opacity: (ind == subP.length - 1) ? 0.0 : 1.0,
                child: Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  ///Returns the [Images] using [Listview] dynamically
  ///inside a [Container]
  ///uses a ScrollController, which controlls how the list will animate & the cur

  Widget _buildImage(double height, double width) {
    ///Testing Purpose, since the [API] throws error for this.
    ///Temporary measure.

    const fakeUrl =
        "https://www.sftravel.com/sites/sftraveldev.prod.acquia-sites.com/files/SanFrancisco_0.jpg";
    const url =
        "https://cdn.pixabay.com/photo/2014/07/10/10/20/golden-gate-bridge-388917_960_720.jpg";

    final dogP = Provider.of<DogPathProvider>(context, listen: false).dogPath;
    final subP = dogP[widget.index].subpaths;
    _itemCount = subP.length;
    return Container(
      height: height * .75,
      width: width,
      child: ListView.builder(
        controller: _scrollImageController,
        scrollDirection: Axis.horizontal,
        itemCount: subP.length,
        itemBuilder: (ctx, ind) {
          _indexFromImage = ind;
          return Image(
            image: subP[ind].imageUrl == fakeUrl
                ? NetworkImage(url)
                : NetworkImage(
                    subP[ind].imageUrl,
                  ),
            fit: BoxFit.fill,
            width: width,
          );
        },
      ),
    );
  }
}
