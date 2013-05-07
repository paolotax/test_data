class MenuViewController < UITableViewController

  extend IB

  #attr_accessor :detailViewController
  
  outlet :activityIndicator
  
  def viewDidLoad
    super
    # if Device.ipad?
    #   self.detailViewController = self.splitViewController.viewControllers.lastObject
    # end
    true
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    if indexPath.section == 0 && indexPath.row == 2
      controller = NelBauleController.new
      self.navigationController.pushViewController(
        controller,
        animated: true
      )
    end
  end

  def importa(sender)
    @actionSheet = UIActionSheet.alloc.initWithTitle("Sei sicuro?",
                                            delegate:self,
                                        cancelButtonTitle:"Annulla",
                                        destructiveButtonTitle:"Importa",
                                        otherButtonTitles:nil)

    @actionSheet.showFromRect(sender.frame, inView:self.view, animated:true)
  end


  def actionSheet(actionSheet, didDismissWithButtonIndex:buttonIndex)
    if buttonIndex != @actionSheet.cancelButtonIndex
      esegui_importazione
    end
    @actionSheet = nil
  end

  def login(sender)
    Store.shared.login {}
  end

  def esegui_importazione
    self.activityIndicator.startAnimating
    
    Store.shared.clear

    @importer = DataImporter.default
    
    @importer.importa_clienti do |result|
      
      main_queue = Dispatch::Queue.main
      main_queue.async do
        "reload_annotations".post_notification
      end
      @importer.importa_classi do |result|
        @importer.importa_libri do |result|
          @importer.importa_adozioni do |result|
            @importer.importa_appunti do |result|
               @importer.importa_righe do |result|               
                Store.shared.persist
                puts "finito"
                self.activityIndicator.stopAnimating
                @importer = nil
                # @importer = Data@Importer.default
                # @importer.importa_clienti do |result|
                #   puts "ari finito"
                #   Store.shared.persist
                #   puts "finito"
                # end
              end
            end
          end
        end
      end
    end
  end

end