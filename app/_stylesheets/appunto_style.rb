Teacup::Stylesheet.new(:appunto_style) do
  
  # style :content_view,
  #   gradient: {
  #     colors: ['#efefef'.uicolor, '#efefef'.uicolor]
  #   }

  style :status,
    frame: CGRectMake(286, 9, 15, 15)

  style :data,
    backgroundColor: UIColor.clearColor,
    font: 'Cassannet Regular'.uifont(12),
    textColor: '#6a6a6a'.uicolor,
    text: '26 sett',
    frame: CGRectMake(234, 10, 45, 14),
    textAlignment: UITextAlignmentRight


  style :destinatario,
    font: 'Cassannet Regular'.uifont(14),
    text: 'Gino',
    textColor: '#535353'.uicolor,
    backgroundColor: UIColor.clearColor,
    frame: CGRectMake(55, 10, 180, 32),
    textAlignment: UITextAlignmentLeft

  style :note,
    backgroundColor: UIColor.clearColor,
    font: 'Cassannet Regular'.uifont(14),
    fontColor: '#6a6a6a'.uicolor,
    text: 'Break - Have a cup of coffee',
    frame: CGRectMake(55, 40, 200, 18),
    lineHeight: 14 * 1.1,
    maxNumberOfLines: 2


  # riga cell

  style :titolo,
    backgroundColor: UIColor.clearColor,
    font: 'Cassannet Regular'.uifont(12),
    textColor: '#6a6a6a'.uicolor,
    text: '',
    frame: CGRectMake(50, 6, 190, 15),
    textAlignment: UITextAlignmentLeft,
    adjustsFontSizeToFitWidth: true

  style :quantita,
    font: 'Cassannet Regular'.uifont(14),
    text: 'Gino',
    textColor: '#535353'.uicolor,
    backgroundColor: UIColor.clearColor,
    frame: CGRectMake(240, 6, 50, 15),
    textAlignment: UITextAlignmentRight

  # riga header view

  style :disclosure_button,
    frame: CGRectMake(0, 4, 36, 36),
    normal: { image: 'carat' },
    selected: { image: 'carat-open' },
    userInteractionEnabled: false

  style :titolo_header,
    backgroundColor: UIColor.clearColor,
    #font: 'Cassannet Regular'.uifont(15),
    textColor: UIColor.whiteColor,
    text: '',
    frame: CGRectMake(40, 0, 241, 44),
    textAlignment: UITextAlignmentLeft,
    adjustsFontSizeToFitWidth: true

  style :quantita_header,
    #font: 'Cassannet Regular'.uifont(14),
    textColor: UIColor.whiteColor,
    backgroundColor: UIColor.clearColor,
    frame: CGRectMake(281, 0, 33, 44),
    textAlignment: UITextAlignmentRight


  # totali cell

  style :importo,
    backgroundColor: UIColor.clearColor,
    font: 'Cassannet Regular'.uifont(14),
    textColor: '#DF0017'.uicolor,
    text: '€ 525,50',
    frame: CGRectMake(155, 6, 75, 15),
    textAlignment: UITextAlignmentRight

  style :copie,
    font: 'Cassannet Regular'.uifont(14),
    text: '1500',
    textColor: '#535353'.uicolor,
    backgroundColor: UIColor.clearColor,
    frame: CGRectMake(240, 6, 50, 15),
    textAlignment: UITextAlignmentRight

  style :telefono,
    backgroundColor: UIColor.clearColor,
    font: 'Cassannet Regular'.uifont(12),
    textColor: '#DF0017'.uicolor,
    text: 'Laurent Sansonetti'.upcase,
    frame: CGRectMake(50, 6, 100, 15),
    textAlignment: UITextAlignmentLeft
end