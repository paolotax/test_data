class AppuntoFormViewController < UITableViewController

  attr_accessor :appunto, :cliente, :presentedAsModal, :saveBlock, :sourceController


  def viewWillAppear(animated)
    super
    
    if presentedAsModal?
      self.navigationItem.setLeftBarButtonItem(UIBarButtonItem.alloc.initWithBarButtonSystemItem(UIBarButtonSystemItemCancel, target:self, action:"cancel:"))
    end
    view.reloadData
  end


  # UITableViewDelegate

  def numberOfSectionsInTableView(tableView)
    2
  end

  def tableView(tableView, numberOfRowsInSection:section)
    if (section == 1)
       @appunto.righe.count + 1
    else
       6
    end
  end

  def tableView(tableView, cellForRowAtIndexPath:indexPath)
    
    if indexPath.section == 0

      if indexPath.row == 2

        cellID = "noteCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleCustom, reuseIdentifier:cellID)
        field = cell.viewWithTag(1123)
        field.text = @appunto.note      
      
      else

        case indexPath.row
        when 0
          column = 'cliente_nome'
        when 1
          column = 'destinatario'
        when 3
          column = 'status'
        when 4
          column = 'email'
        when 5
          column = 'telefono'
        end

        cellID = "#{column}Cell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleRightDetail, reuseIdentifier:cellID)
        
        value = @appunto.valueForKey(column)
        if column == 'status'
          value = value.split("_").join(" ")
        end
        cell.detailTextLabel.text = value
      end

    elsif indexPath.section == 1

      if indexPath.row == 0
        cellID = "addRigaCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= UITableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
      else
        cellID = "rigaCell"
        cell = tableView.dequeueReusableCellWithIdentifier(cellID) 
        cell ||= RigaTableViewCell.alloc.initWithStyle(UITableViewCellStyleDefault, reuseIdentifier:cellID)
        cell.riga = @appunto.righe.objectAtIndex(indexPath.row - 1)
      end
    end  
    cell
  end

  def tableView(tableView, heightForRowAtIndexPath:indexPath)
    if indexPath.section == 0 && indexPath.row == 2
      97
    else
      44
    end
  end

  def tableView(tableView, commitEditingStyle:editingStyle, forRowAtIndexPath:indexPath)
    # self.fetchControllerForTableView(tableView).objectAtIndexPath(indexPath).remove
    # tableView.updates do
    #   if tableView.numberOfRowsInSection(indexPath.section) == 1
    #     tableView.deleteSections(NSIndexSet.indexSetWithIndex(indexPath.section), withRowAnimation:UITableViewRowAnimationFade)
    #   end
    #   tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation:UITableViewRowAnimationFade)
    # end
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:true)
  end





  # segues
  
  def prepareForEditDestinatarioSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.destinatario
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(1, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.destinatario = text
        return true
      end
    )
  end
 
  def prepareForEditNoteSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.note
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(2, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        temp = cell.viewWithTag(1123)
        temp.setText(text)
        @appunto.note = text
        return true
      end
    )
  end

  def prepareForEditEmailSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.email
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(4, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.email = text
        return true
      end
    )
  end

  def prepareForEditTelefonoSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.testo = @appunto.telefono
    editController.setTextChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(5, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.telefono = text
        return true
      end
    )
  end

  def prepareForEditStatoSegue(segue, sender:sender)
    editController = segue.destinationViewController
    editController.appunto = @appunto
    editController.setStatoChangedBlock( lambda do |text, error|
        path = NSIndexPath.indexPathForRow(3, inSection:0)
        cell = self.tableView.cellForRowAtIndexPath(path)
        cell.detailTextLabel.setText(text)
        @appunto.status = text
        return true
      end
    )
  end

  def prepareForShowClienteSegue(segue, sender:sender)
    editController = segue.destinationViewController.visibleViewController
    editController.cliente = @appunto.cliente
  end

  def prepareForAddRigaSegue(segue, sender:sender)
    segue.destinationViewController.appunto = @appunto
  end

  def prepareForEditRigaSegue(segue, sender:sender)
    indexPath = self.tableView.indexPathForCell(sender)
    @riga = self.tableView.cellForRowAtIndexPath(indexPath).riga
    if @riga.remote_appunto_id != @appunto.remote_id 
      @riga.remote_appunto_id = @appunto.remote_id 
    end
    segue.destinationViewController.riga = @riga
    segue.destinationViewController.appunto = @appunto
  end

  def prepareForSegue(segue, sender:sender)
    if segue.identifier.isEqualToString("editDestinatario") 
      self.prepareForEditDestinatarioSegue(segue, sender:sender)
    elsif segue.identifier.isEqualToString("editNote") 
      self.prepareForEditNoteSegue(segue, sender:sender)
    elsif segue.identifier.isEqualToString("editStato") 
      self.prepareForEditStatoSegue(segue, sender:sender)
    elsif segue.identifier.isEqualToString("editTelefono") 
      self.prepareForEditTelefonoSegue(segue, sender:sender)
    elsif segue.identifier.isEqualToString("editEmail") 
      self.prepareForEditEmailSegue(segue, sender:sender)  
    elsif segue.identifier.isEqualToString("showCliente") 
      self.prepareForShowClienteSegue(segue, sender:sender)
    elsif segue.identifier.isEqualToString("editRiga") 
      self.prepareForEditRigaSegue(segue, sender:sender)
    elsif segue.identifier.isEqualToString("addRiga") 
      self.prepareForAddRigaSegue(segue, sender:sender)
    end
  end


  # save

  def save(sender)

    if @appunto.isUpdated
      @appunto.updated_at = Time.now
    end
    Store.shared.save
    Store.shared.persist
        
    puts @appunto.remote_id
    self.appunto.save_to_backend  

    "reload_appunti_list".post_notification
    "reload_appunti_collections".post_notification

    if Device.ipad?
      self.dismissViewControllerAnimated(true, completion:nil)
    else
      self.navigationController.popViewControllerAnimated(true)
    end 
  end

  def cancel(sender)

    Store.shared.context.rollback
    if Device.ipad?
      self.dismissViewControllerAnimated(true, completion:nil)
    else
      self.navigationController.popViewControllerAnimated(true)
    end
  end

  private

    def presentedAsModal?
      self.presentedAsModal == true
    end

end