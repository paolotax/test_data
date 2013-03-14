class EditReminderController < UIViewController
  
  extend IB

  outlet :titleText
  outlet :dateLabel
  outlet :datePicker

  attr_accessor :appunto, :reminderChangedBlock, :eventKitManager

  def viewDidLoad
    super

    self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
  
    # if (![[self navigationItem] rightBarButtonItem]) {
    #   [[self navigationItem] setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)]];
  end
  
  def viewWillAppear(animated)
    super
    "dismissView".add_observer(self, :dismiss)
    # if self.textView
    #   self.textView.text = @testo
    #   self.textView.becomeFirstResponder
    # else
    #   self.textField.text = @testo
    #   self.textField.becomeFirstResponder
    # end
  end

  def viewWillDisappear(animated) 
    NSNotificationCenter.defaultCenter.removeObserver(self)
  end

  def handleReminderCompletion

    @text = titleText.text
    @date = datePicker.date

    if @eventKitManager == nil
      @eventKitManager = EventKitManager.alloc.init
      "RemindersAccessGranted".add_observer(self, :performReminderOperations, @eventKitManager)
      "EventsAccessGranted".add_observer(self, :performEventOperations, @eventKitManager)
    else
      self.performReminderOperations
    end
  end

  def performEventOperations
    puts "event granted"
    #@eventKitManager.addReminderWithTitle("Ciao da Youpropa", dueTime:NSDate.new)
  end

  def performReminderOperations
    puts "reminder granted"
    @eventKitManager.addReminderWithTitle(@text, dueTime:@date)
    error = Pointer.new(:object)
    success = @reminderChangedBlock.call(@text, @date, error)
    if (success) 
      "dismissView".post_notification
      return true
    else
      return false
    end
  end  

  def dismiss
    main_queue = Dispatch::Queue.main
    main_queue.async do
      self.navigationController.popViewControllerAnimated(true)
    end
  end


  def done(sender)
    self.handleReminderCompletion
  end
  
  def cancel(sender)
    "dismissView".post_notification
  end

  #pragma mark - UITextFieldDelegate

  def textFieldShouldReturn(textField)
    #return self.handleTextCompletion
  end



end