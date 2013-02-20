class TestModalPickerView < UIViewController

  TIPI_CLIENTI = ['Scuola Primaria', 'Istituto Comprensivo', 'Direzione Didattica', 'Cartolibreria', 'Persona Fisica', 'Ditta', 'Comune']
  
  extend IB

  attr_accessor :items

  outlet :pickResultLabel

  def viewDidLoad
    super

    # edit = UITextField.alloc.initWithFrame([[10,200], [120,44]])
    # self.view.addSubview(edit)


    # @pickResultLabel.text = TIPI_CLIENTI[0]

    # tapRecognizer = UITapGestureRecognizer.alloc.initWithTarget(@pickResultLabel, action:"sendPick")
    # @pickResultLabel.addGestureRecognizer(tapRecognizer)
  end

  def sendPick
    pickerView = TAXModalPickerView.alloc.initWithValues(TIPI_CLIENTI)
    pickerView.setSelectedValue @pickResultLabel.text
    pickerView.presentInView(self.view, withBlock: lambda do | madeChoice, value |
        if madeChoice == true
          @pickResultLabel.text = value
        end
      end
    )
  end

  def killApp
    exit(0)
  end

  def login
    Store.shared.login {}
  end

  def importa
    Store.shared.clear
    Store.shared.login do
      Store.shared.backend.getObjectsAtPath("api/v1/clienti",
                              parameters: nil,
                              success: lambda do |operation, result|
                                                puts "Clienti: #{result.array.count}"
                                                self.addAppunti
                                              end,
                              failure: lambda do |operation, error|
                                                puts error
                                               end)
   end
  end

  def addAppunti
    Store.shared.backend.getObjectsAtPath("api/v1/appunti",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Appunti: #{result.array.count}"
                                                  self.addLibri
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def addLibri
    Store.shared.backend.getObjectsAtPath("api/v1/libri",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Libri: #{result.array.count}"
                                                  self.addRighe
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end

  def addRighe
    Store.shared.backend.getObjectsAtPath("api/v1/righe",
                                parameters: nil,
                                success: lambda do |operation, result|
                                                  puts "Righe: #{result.array.count}"
                                                end,
                                failure: lambda do |operation, error|
                                                  puts error
                                                end)
  end


end