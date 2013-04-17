class EditMultipleClassiController < UIViewController

  extend IB

  attr_accessor :testo, :selected_classi

  outlet :labelClassi
  outlet :textView
  outlet :textField
  outlet :addSwitch

  attr_accessor :textChangedBlock

  def viewDidLoad
    super

  end
  


  def viewWillAppear(animated)
    super

    if @selected_classi.count == 1

      self.labelClassi.text = "#{@selected_classi[0].num_classe} #{@selected_classi[0].sezione} - #{@selected_classi[0].cliente.nome}"
      self.textField.text = @selected_classi[0].insegnanti
      self.textView.text = @selected_classi[0].note
    
    else
      self.addSwitch.on = true
      self.labelClassi.text = "#{@selected_classi.count} classi selezionate"    
    
    end
    self.textField.becomeFirstResponder
  end
  
  def handleTextCompletion

    @selected_classi.each do |classe|
      if self.addSwitch.isOn  && @selected_classi.count >= 1
        classe.insegnanti = "#{classe.insegnanti} #{self.textField.text}".strip
        classe.note = "#{classe.note} #{self.textView.text}".strip
      else
        classe.note = self.textView.text
        classe.insegnanti = self.textField.text
      end
      
      classe.update
      classe.save_to_backend
    end  

    Store.shared.persist
    "reload_classi_collections".post_notification
    "dismiss_popover".post_notification
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