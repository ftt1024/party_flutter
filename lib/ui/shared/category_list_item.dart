import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:zgadula/localizations.dart';
import 'package:zgadula/store/category.dart';

import 'package:zgadula/ui/theme.dart';
import 'package:zgadula/models/category.dart';
import 'category_image.dart';

class CategoryListItem extends StatefulWidget {
  CategoryListItem({
    this.index,
    this.category,
    this.onTap,
    this.onFavoriteToggle,
    this.isFavorite = false,
  });

  final int index;
  final Category category;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  @override
  _CategoryListItemState createState() => _CategoryListItemState();
}

class _CategoryListItemState extends State<CategoryListItem>
    with TickerProviderStateMixin {
  static const textAnimationDuration = Duration(milliseconds: 1000);

  AnimationController animationController;
  Animation<double> animation;

  @override
  void initState() {
    super.initState();
    initAnimations();
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  initAnimations() {
    int index = widget.index;
    animationController =
        AnimationController(vsync: this, duration: textAnimationDuration);
    animation =
        CurvedAnimation(parent: animationController, curve: Curves.decelerate);

    Future.delayed(Duration(milliseconds: 75 * min(index, 8))).then((_) {
      animationController.forward();
    });
  }

  Widget buildMetaItem(String text, [IconData icon]) {
    return Opacity(
      opacity: 0.7,
      child: Row(
        children: <Widget>[
          icon != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: Icon(icon, size: 14),
                )
              : null,
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: ThemeConfig.categoriesMetaSize,
            ),
          ),
        ].where((o) => o != null).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    int questionCount = widget.category.questions.length;

    return GestureDetector(
      onTap: widget.onTap,
      child: ScaleTransition(
        scale: animation,
        child: Stack(
          children: [
            Hero(
              tag: 'categoryImage-${widget.category.name}',
              child: CategoryImage(photo: widget.category.getImagePath()),
            ),
            Positioned(
              right: 0.0,
              left: 0.0,
              bottom: 0.0,
              top: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Text(
                      widget.category.name,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: ThemeConfig.categoriesTextSize,
                      ),
                    ),
                    ScopedModelDescendant<CategoryModel>(
                      builder: (context, child, model) {
                        return Positioned(
                          bottom: 10,
                          left: 10,
                          child: buildMetaItem(
                            model.getPlayedCount(widget.category).toString(),
                            Icons.play_arrow,
                          ),
                        );
                      },
                    ),
                    questionCount > 0
                        ? Positioned(
                            bottom: 10,
                            right: 10,
                            child: buildMetaItem(
                              AppLocalizations.of(context).categoryItemQuestionsCount(questionCount),
                            ),
                          )
                        : null,
                  ].where((o) => o != null).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
