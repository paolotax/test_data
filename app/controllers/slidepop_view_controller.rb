class SlidepopViewController < UIViewController
  
  ANIMATION_DURATION = 0.5

  attr_accessor :rootViewController
  attr_accessor :popoverViewController

  def viewDidLoad
    super
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.rootViewController = self.storyboard.instantiateViewControllerWithIdentifier("MainController")
    self.rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
  end

  def viewWillAppear(animated)
    super

    if self.popoverViewController
      self.popoverViewController.dismissPopoverAnimated(true)
    end

    if (self.childViewControllers.count == 0) 
      self.addController(self.rootViewController)
      rootView = self.rootViewController.view;
      rootView.frame = self.view.bounds
      self.view.addSubview(rootView)
      self.rootViewController.didMoveToParentViewController(self)
    end
  end

  def addController(viewController)
    viewController.willMoveToParentViewController(self)
    self.addChildViewController(viewController)
  end

  def topMostViewController
    self.childViewControllers.lastObject
  end

  def pushViewController(viewController)
   
    topVC = self.topMostViewController
    self.addController(viewController)

    viewController.view.frame = self.view.bounds
    self.view.addSubview(viewController.view)
    viewController.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0)
       
    UIView.animateWithDuration(ANIMATION_DURATION, 
          animations:-> {
            topVC.view.alpha = 0.5;
            topVC.view.transform = CGAffineTransformMakeScale(0.7, 0.7)
            viewController.view.transform = CGAffineTransformIdentity
          }, 
          completion:lambda do |finished|
            viewController.didMoveToParentViewController(self)
            
            if topVC.is_a? ClienteDetailController
              puts topVC.cliente
              topVC.view.removeFromSuperview
              topVC.removeFromParentViewController
            end

          end
    )
   
  end

  def popViewController(sourceController)
    
    index = self.childViewControllers.count - 2
    targetVC = self.childViewControllers[index]
    topVC = self.topMostViewController

    topVC.willMoveToParentViewController(nil)
    
    previousTransform = targetVC.view.transform
    targetVC.view.transform = CGAffineTransformIdentity
    targetVC.view.frame = self.view.bounds
    targetVC.view.transform = previousTransform
    
    UIView.animation_chain {
      targetVC.view.alpha = 1.0
      targetVC.view.transform = CGAffineTransformIdentity
      topVC.view.slide :right
      targetVC.selectItemInMap(sourceController.cliente)

    }.and_then {
      sourceController.view.removeFromSuperview
      sourceController.removeFromParentViewController
    }.start


    # UIView.animateWithDuration(ANIMATION_DURATION, 
    #   animations:-> {
    #     targetVC.view.alpha = 1.0
    #     targetVC.view.transform = CGAffineTransformIdentity
    #     topVC.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0)
    #   }, 
    #   completion: lambda do |finished|
    #     # topView non ha più view ma float bug
    #     topVC = self.topMostViewController
    #     #topVC.view.removeFromSuperview if topVC.view
    #     topVC.removeFromParentViewController
    #   end
    # )
  end

  def replaceViewController(cliente)

    index = self.childViewControllers.count - 2
    targetVC = self.childViewControllers[index]
    topVC = self.topMostViewController
    
    topVC.willMoveToParentViewController(nil)
    
    
    previousTransform = targetVC.view.transform
    targetVC.view.transform = CGAffineTransformIdentity
    targetVC.view.frame = self.view.bounds
    targetVC.view.transform = previousTransform
    
    
    UIView.animateWithDuration(0.3, 
      animations:-> {
        targetVC.view.alpha = 1.0
        targetVC.view.transform = CGAffineTransformIdentity
        topVC.view.transform = CGAffineTransformMakeTranslation(self.view.bounds.size.width, 0)
      }, 
      completion: lambda do |finished|
        topVC = self.topMostViewController
        topVC.removeFromParentViewController
        clienteDetail = self.storyboard.instantiateViewControllerWithIdentifier("ClienteDetailController")
        clienteDetail.cliente = cliente
        self.pushViewController(clienteDetail)
      end
    )

  end


  # splitView delegates

  # def splitViewController(svc, shouldHideViewController:vc, inOrientation:orientation)
  #   return false
  # end

  def splitViewController(svc, willHideViewController:vc, withBarButtonItem:barButtonItem, forPopoverController:pc)
    barButtonItem.title = "Menu"
    self.navigationItem.setLeftBarButtonItem(barButtonItem)
    self.popoverViewController = pc
  end
  
  def splitViewController(svc, willShowViewController:avc, invalidatingBarButtonItem:barButtonItem) 
    self.navigationItem.setLeftBarButtonItems([], animated:false)
    self.popoverViewController = nil
  end

end