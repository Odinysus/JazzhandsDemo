# JazzHandsDemo
a demo of JazzHands

---

   ![Demo](https://cl.ly/0m1F1B3S1D0a/download/Screen%20Recording%202016-10-29%20at%2010.21%20PM.gif)  

3.  类图  
  ![jazzhand](https://cl.ly/2U1G2c3o2G3j/download/Class%20Diagram.png)

  **IFTTTAnimatior**   
  导演类,里面有一个动画(`IFTTTAnimation`)数组管理所有动画的添加/删除/执行.  

  **IFTTTAnimatable**   
  执行动画类.
  *重要: 定义了核心协议(接口),`animate:(CGFloat)time;` 计算每一个时间点当前对象的值.每一种动画都要实现这个接口.如`IFTTTAlphaAnimation`类,计算一个时间点对应的对象的alpha值*

  **IFTTTAnimation**
  动画基类,定义了一个对象的动画.仅仅只是对类中的`IFTTTFilemstrip`进行一个简单的封装.

  >注: 每种动画都继承IFTTTAnimation和实现<IFTTTAnimatable>协议才会正常工作.

  **IFTTTFilmstrip**
  胶片类,有一个关键帧(IFTTTKeyframe)数组.,添加/修改/获取对应关键帧(IFTTTKeyframe)的值.通过valueAtTime:可以计算两个相邻关键帧之间的的值.这个值在执行动画时` - animate`使用.

  **IFTTTKeyframe**
  关键帧类,描述每一个关键帧的时间对应的值.  

4. 分析:
jazzhand主要应用在`scrollviews`,同时封装了`IFTTTAnimatedPagingScrollViewController`方便我们继承使用.目前这个类`scrollview`只支持横向滚动,并不支持纵向滚动.jazzhand框架是基于关键帧的动画,这个概念其实跟`Core Animation` 的概念是一样的. 只不过跟core Animation有不同一点的是,jazzhand框架的动画驱动是坐标驱动.  
举个例子,在`Core Animation`中,我们只需要设置轨迹,方向,时间就可以提交了.接下就由`Core Animation`负责计算,就可以看到App能执行一段动画.这里设置了时间5s.在APP接下来的5s中,`Core Animation`每1/30秒重新计算一次`imageview`的位置并调用`[self ifNeedLayout]`方法进行更行.然后就形成了我们所看到的动画.

		  [UIView beginAnimations:@"jk" context:nil];
		//    设置动画的方向
		    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:imageView cache:YES];
		//    设置动画持续时间
		    [UIView setAnimationDuration:5];
		//   设置动画效果过渡的状态
		    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		//    提交动画
		    [UIView commitAnimations];
		}

  但是Jazzhand中,却以`scrollview.contentOffset`作为动画执行的time,在`[scrollview didScroll]`代理中重新计算视图的位置.
![坐标位移](https://cl.ly/2G3C1y170g3o/download/x-zhou.png)  

	在Jazzhand中有一个重要的方法
  ````
  - (void)keepView:(UIView *)view
           onPages:(NSArray *)pages
           atTimes:(NSArray *)times
       withOffsets:(NSArray *)offsets    
     withAttribute:(IFTTTHorizontalPositionAttribute)attribute
  ````

	> pages和offsets的个数要相同.不然会产生致命错误(crash)

  其中每个page和time对应的是:
  view.frame.size.x = page * pageWidth
  scrollview.contentOffset = time * pageWidth

  当time = 1时, 即scrollview滚到第二页的时候,scrollview.contentOffset=(pageWidth * 1).然后我们必须设置时间time所对应的view的位置.可以想象每拖动一个页面,相当于view对象进行时间0到1的动画.
每一个动画(animation)都拥有一个胶卷(filmstrip),每一个胶卷都包含该了该动作的所有关键帧(keyframe).随着屏幕拖拽,JazzHands会根据约束和时间(contentOffset)计算对象的位置.只要刷新的频率只够高.我们人眼就看不出是重新画上去,而是连续的动画了.

5. 使用:

	1.  

	            @interface IntrotductionController:IFTTTAnimatedPagingScrollViewController

	`IFTTTAnimatedPagingScrollViewController`
	继承`viewcontroller`,有子成员`scrollview`,封装了`contentview`.所以只需要将对象加入到`contentview`中就可以.
	2. 重载 `numberOfPage`方法系统默认是2
	3. 如果不需要,就不要给对象添加约束.  

	   > 不要给x值添加约束. 原因见4.

	4. `[self keepView:self.circle onPages:@[@(0), @(1)]];` 设置对象的x值的关键帧. 这句代码的意思是,当视图view移动到`scrollview`的`contentOffset`为0时`circle`的位置也为0, 当拖动到`contentOffset`为1时,`circle`的位置也是1,这句代码内部帮对象添加了x值的约束.如果你之前为x值添加其他约束,这里在运行时候回出现约束冲突错误.同时我们只能选择对象在屏幕中左中右三个相对位置.

		>注: 使对象相对于屏幕位置不动的方法   

				// 设置time即contentOffset不变,即使相对屏幕不变.
				// 在index-1滑动到index时,leimuImgHeart的位置从index-1.15滑动到index-0.15.两者滑动的距离相等,速度相等.
				// 所以视觉上是相对于屏幕位置不变.同时,第4中不设置times参数也是默认相对于屏幕位置不变
		    [self keepView:leimuImgHeart onPages:@[@(index-1.15),@(index-0.15), @(index-1.15)] atTimes:@[@(index-1),@(index),@(index+1)] withAttribute:IFTTTHorizontalPositionAttributeCenterX offset:0];  

		Time变化引起offset变化,leimuImgHeart也得同步跟time一起变化
	5. 定义你自己的动画  

					// 最好使用autolayout固定视图的位置
	        NSLayoutConstraint * topConstraint = [NSLayoutConstraint constraintWithItem:leimuImgHeart      attribute:NSLayoutAttributeCenterY                      relatedBy:NSLayoutRelationEqual                  toItem:self.contentView
	              attribute:NSLayoutAttributeTop          multiplier:1.0 constant:0.f];
		    [self.contentView addConstraint:topConstraint];
		    // 添加一个约束帧动画,即约束随time的变化而变化
		    IFTTTConstraintMultiplierAnimation *constantAnimation = [IFTTTConstraintMultiplierAnimation animationWithSuperview:self.contentView         constraint:topConstraint                attribute:IFTTTLayoutAttributeHeight             referenceView:self.contentView];
		    [constantAnimation addKeyframeForTime:index-1 multiplier:-0.2f];
		    [constantAnimation addKeyframeForTime:index multiplier:0.3f];
		    [self.animator addAnimation:constantAnimation];

