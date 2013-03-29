class SetPinController < UITableViewController

  extend IB

  attr_accessor :delegate, :selectedPins

  outlet :switch_da_fare
  outlet :switch_in_sospeso
  outlet :switch_nel_baule
  outlet :switch_scuole_primarie
  outlet :switch_altri_clienti

  def viewDidLoad
    super
    self.navigationItem.title = "Scegli Clienti"
  end

  def viewWillAppear(animated)
    super
    if self.selectedPins.include? "switch_da_fare"
      self.switch_da_fare.on = true
    end
    if self.selectedPins.include? "switch_in_sospeso"
      self.switch_in_sospeso.on = true
    end
    if self.selectedPins.include? "switch_nel_baule"
      self.switch_nel_baule.on = true
    end
    if self.selectedPins.include? "switch_scuole_primarie"
      self.switch_scuole_primarie.on = true  
    end
    if self.selectedPins.include? "switch_altri_clienti"  
      self.switch_altri_clienti.on = true
    end
  end

  def viewDidAppear(animated)
    self.contentSizeForViewInPopover = self.tableView.contentSize
  end

  def switchValueDidChange(sender)

    selectedPins = []

    if self.switch_da_fare.isOn == true
      selectedPins << "switch_da_fare"
    end
    if self.switch_in_sospeso.isOn == true
      selectedPins << "switch_in_sospeso"
    end
    if self.switch_nel_baule.isOn == true
      selectedPins << "switch_nel_baule"
    end
    if self.switch_scuole_primarie.isOn == true
      selectedPins << "switch_scuole_primarie"
    end
    if self.switch_altri_clienti.isOn == true
      selectedPins << "switch_altri_clienti"
    end

    @delegate.setPinController(self, didChangedPin:selectedPins)
  end

  def tableView(tableView, didSelectRowAtIndexPath:indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated:false)
    if indexPath.row == 5
      @delegate.resetBaule
    elsif indexPath.row == 6
      @delegate.smartBaule
    end   
  end
end