include SugarCube::Adjust 

class AppDelegate



  def application(application, didFinishLaunchingWithOptions:launchOptions)

    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)

    AFNetworkActivityIndicatorManager.sharedManager.enabled = true

    if Device.ipad?
      storyboard = UIStoryboard.storyboardWithName("MainStoryboard_iPad", bundle:nil)
      @window.rootViewController = storyboard.instantiateInitialViewController
      splitViewController = self.window.rootViewController
      masterController = splitViewController.viewControllers.lastObject
      splitViewController.delegate = masterController
    else
      #storyboard = UIStoryboard.storyboardWithName("MainStoryboard_iPhone", bundle:nil)
      storyboard = UIStoryboard.storyboardWithName("Example", bundle:nil)
      @window.rootViewController = storyboard.instantiateInitialViewController
    end

    @window.makeKeyAndVisible
    true
  end

  def window
    @window
  end

  def applicationWillEnterForeground(application)
  end

  def applicationDidEnterBackground(application)
    puts "Did Enter Background"
    saveContext
    puts Store.shared.stats
  end 

  def applicationDidBecomeActive(application)
    puts "Did become Active"
    Store.shared.login do
      puts "logged in"
    end
    puts Store.shared.stats
  end

  def applicationWillTerminate(application)
    puts "Will Terminate"
    saveContext
    puts Store.shared.stats
  end 
    
  def saveContext
    error = Pointer.new(:object)
    mainContext = Store.shared.context
    mainContext.save(error)

    error = Pointer.new(:object)
    persistentStore = Store.shared.store.persistentStoreManagedObjectContext
    persistentStore.save(error)


    # unless managedObjectContext.nil?
    #   if (managedObjectContext.hasChanges && !managedObjectContext.save(error))
    #     puts "Unresolved error #{error}, #{userInfo}"
    #     abort()
    #   end

    #   unless error
    #     puts "USCITO"
    #   end
    # end
  end

end
