class EditReminderController < UIViewController
  
  extend IB

  outlet :titleText
  outlet :dateButton
  outlet :tableView

  #outlet :dateText  
  #outlet :datePicker

  attr_accessor :appunto, :reminderChangedBlock, :date_picker#, :dateFormatter, :eventKitManager

  SUGGESTIONS = ["ricordati", "telefona", "spedisci", "controlla", "fattura", "appuntamento"]

  def init
    super && self.tap {
      @data_scadenza = NSDate.now
    }
  end
  
  def viewDidLoad
    super

    @dateFormatter = NSDateFormatter.alloc.init
    @dateFormatter.setLocale(NSLocale.currentLocale)
    @dateFormatter.setDateStyle(NSDateFormatterFullStyle)
    @dateFormatter.setTimeStyle(NSDateFormatterShortStyle) 

    # DatePiker nella keyBoard con textfield
    # self.dateText.delegate = self
    # datePicker = UIDatePicker.alloc.init
    # self.dateText.inputView = datePicker;
  end
  
  def viewWillAppear(animated)
    super
    self.navigationItem.rightBarButtonItem = UIBarButtonItem.done { handleReminderCompletion }

    setup_date_picker
    "dismissView".add_observer(self, :dismiss)

    self.titleText.text = "#{@appunto.cliente.nome} - #{@appunto.destinatario}" if appunto
    self.dateButton.setTitle(@dateFormatter.stringFromDate(NSDate.new), forState:UIControlStateNormal)
  end

  def viewWillDisappear(animated) 
    NSNotificationCenter.defaultCenter.removeObserver(self)
  end

  # def disablesAutomaticKeyboardDismissal
  #   self.topViewController.disablesAutomaticKeyboardDismissal 
  # end 


  def handleReminderCompletion

    @text = titleText.text
    @date = date_picker.date

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

  def show_date_picker
    self.titleText.endEditing(true)
    self.view.resignFirstResponder
    @modal_view.fade_in
    @keyboard_view.slide :up
  end

  def done_modal
    self.dateButton.setTitle(@dateFormatter.stringFromDate(@date_picker.date), forState:UIControlStateNormal)
    cancel_modal
  end
  
  def cancel_modal
    @modal_view.fade_out
    @keyboard_view.slide :down
  end
    
  #pragma mark - UITextFieldDelegate

  # def textFieldShouldReturn(textField)
  #   #return self.handleTextCompletion
  # end

  # def textFieldShouldBeginEditing(textField)
  #   if textField == @dateText
  #     textField.resignFirstResponder
  #     self.titleText.endEditing(true)
  #     show_date_picker
  #     false
  #   else
  #     true
  #   end
  # end


  def numberOfSectionsInTableView(tableView)
    1
  end

  def tableView(tableView, numberOfRowsInSection:section)
    6
  end

  def tableView(tableView, titleForHeaderInSection:section)
    return "Suggerimenti"
  end


  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    cellID = "suggestionCell"
    cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
    cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
    cell.textLabel.text = "#{SUGGESTIONS[indexPath.row]} #{@appunto.cliente.nome} #{@appunto.destinatario}"
    cell
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
    cell = tableView.cellForRowAtIndexPath(indexPath)
    self.titleText.text = cell.textLabel.text
  end


  private

    def setup_date_picker
      
      @modal_view = UIControl.alloc.initWithFrame(self.view.bounds)
      @modal_view.backgroundColor = :black.uicolor(0.5)
      @modal_view.alpha = 0.0
      @modal_view.on :touch do
        cancel_modal
      end
      self.view << @modal_view

      @keyboard_view = UIView.alloc.initWithFrame([[0, self.view.bounds.height], [320, 260]])
      self.view << @keyboard_view

      nav_bar = UINavigationBar.alloc.initWithFrame([[0, 0], [self.view.bounds.width, 44]])
      item = UINavigationItem.new
      item.leftBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
          UIBarButtonSystemItemCancel,
          target: self,
          action: :cancel_modal)

      item.rightBarButtonItem = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
          UIBarButtonSystemItemDone,
          target: self,
          action: :done_modal)
      nav_bar.items = [item]
      @keyboard_view << nav_bar

      #@picker_delegate = AwesomeDatePickerDelegate.new
      @date_picker = UIDatePicker.alloc.initWithFrame([[0, 44], [self.view.bounds.width, 216]])
      #@date_picker.addTarget(self, action:"change_deadline", forControlEvents:UIControlEventValueChanged )
      #@date_picker.showsSelectionIndicator = true
      #@date_picker.delegate = @date_picker.dataSource = @picker_delegate
      #@date_picker.selectRow(@awesomeness, inComponent:0, animated:false)
      @keyboard_view << @date_picker
    end

    def  change_deadline
      self.dateButton.setTitle("myTitle", forState:UIControlStateNormal)
    end

end