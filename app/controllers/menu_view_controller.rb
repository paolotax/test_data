class MenuViewController < UITableViewController

  extend IB

  attr_accessor :detailViewController
  
  outlet :activityIndicator
  
  def login(sender)
    Store.shared.login {}
  end
  
  def viewDidLoad
    super
    if Device.ipad?
      self.detailViewController = self.splitViewController.viewControllers.lastObject
    end
    true
  end

  def importa(sender)
    self.activityIndicator.startAnimating
    importer = DataImporter.default
    importer.importa_clienti do |result|
      
      main_queue = Dispatch::Queue.main
      main_queue.async do
        "reload_annotations".post_notification
      end

      importer.importa_classi do |result|
        importer.importa_libri do |result|
          importer.importa_adozioni do |result|
            importer.importa_appunti do |result|
              importer.importa_righe do |result|
                #importer.importa_clienti do |result|
                  
                  #lo devo rifare seno scaglia
                  # main_queue = Dispatch::Queue.main
                  # main_queue.async do
                  #   "reload_annotations".post_notification
                  # end
                  puts "finito"
                  self.activityIndicator.stopAnimating
                #end
              end
            end
          end
        end
      end
    end
  end

end