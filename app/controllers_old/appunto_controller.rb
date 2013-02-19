class AppuntoController < UITableViewController
  attr_accessor :appunto, :is_update

  def text
    @cell.textField.text
  end
  
  def viewDidLoad
    super # get keyboard notifications
    view.dataSource = view.delegate = self
  end

  CellID = 'CellIdentifier'
  def viewWillAppear(animated)
    self.title = 'Appunto'
    
    @cell ||= UITableViewTextFieldCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:CellID).tap do |c|
      c.textLabel.text = 'Destinatario'
      c.textField.tap do |tf|
        tf.placeholder = 'Inserisci destinatario'
        tf.returnKeyType = UIReturnKeyDone
        tf.delegate = self
      end
      c
    end
    @cell.textField.text = appunto.destinatario
  
    setEditing(true, animated:true)
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown
  end

  def tableView(tableView, numberOfRowsInSection:section)
    1
  end
  
  def tableView(tableView, editingStyleForRowAtIndexPath:indexPath)
    UITableViewCellEditingStyleNone
  end
  
  def tableView(tableView, shouldIndentWhileEditingRowAtIndexPath:indexPath)
    false
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    @cell
  end
 
  def textFieldShouldReturn(textField)
    textField.resignFirstResponder
    true
  end
end