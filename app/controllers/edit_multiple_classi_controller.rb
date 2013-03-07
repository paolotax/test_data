class EditMultipleClassiController < UIViewController

  extend IB

  attr_accessor :testo, :selected_classi

  outlet :labelClassi
  outlet :textView
  outlet :textField

  attr_accessor :textChangedBlock

  def viewDidLoad
    super

    # self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
  
    # if (![[self navigationItem] rightBarButtonItem]) {
    #   [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)]];
  end
  


  def viewWillAppear(animated)
    super

    self.labelClassi.text = "#{@selected_classi.count} classi selezionate"

    if self.textView
      self.textView.text = @testo
      self.textView.becomeFirstResponder
    else
      self.textField.text = @testo
      self.textField.becomeFirstResponder
    end
  end
  
  def handleTextCompletion

    @selected_classi.each do |classe|
      classe.note = self.textField.text
      classe.update
    end  

    Store.shared.persist
    "reload_classi_collections".post_notification
    "dismiss_popover".post_notification

    # error = Pointer.new(:object)
    # success = @textChangedBlock.call(text, error)
    # if (success) 
    #   self.navigationController.popViewControllerAnimated(true)
    #   return true
    # else
    #   alertView = UIAlertView.alloc.initWithTitle("Error", message:error.localizedDescription, delegate:nil, cancelButtonTitle:"Chiudi", otherButtonTitles:nil);
    #   alertView.show
    #   return false
    # end
  end  


  def done(sender)
    self.handleTextCompletion
  end
  
  def cancel(sender)
    "reload_classi_collections".post_notification
    "dismiss_popover".post_notification
  end

  #pragma mark - UITextFieldDelegate

  def textFieldShouldReturn(textField)
    return self.handleTextCompletion
  end


end