class ClassiCollectionController < UIViewController

  extend IB

  attr_accessor :cliente, :classi_prime, :classi_seconde, :classi_terze, :classi_quarte, :classi_quinte, :selected_classi
  
  outlet :classiCollectionView

  def viewDidLoad
    super

    self.classiCollectionView.registerClass(ClasseItem, forCellWithReuseIdentifier:"classeItem")
    self.classiCollectionView.setShowsHorizontalScrollIndicator(false)
    self.classiCollectionView.setShowsVerticalScrollIndicator(false)
    self.classiCollectionView.setAllowsMultipleSelection(true)
  end

  def viewWillAppear(animated)
    super
    "reload_classi_collections".add_observer(self, :reload)
    reload
  end

  def viewWillDisappear(animated)
    super
    "reload_classi_collections".remove_observer(self, :reload)
  end
 
  def reload
    Cliente.reset
    Classe.reset
    Adozione.reset
    self.selected_classi = []
    self.classiCollectionView.reloadData
  end

  def classi_prime
    @classi_prime ||= begin
      @classi_prime = []
      @classi_prime = sorted_classi.select {|c| c.num_classe == 1}
      @classi_prime
    end
  end

  def classi_seconde
    @classi_seconde ||= begin
      @classi_seconde = []
      @classi_seconde = sorted_classi.select {|c| c.num_classe == 2}
      @classi_seconde
    end
  end

  def classi_terze
    @classi_terze ||= begin
      @classi_terze = []
      @classi_terze = sorted_classi.select {|c| c.num_classe == 3}
      @classi_terze
    end
  end

  def classi_quarte
    @classi_quarte ||= begin
      @classi_quarte = []
      @classi_quarte = sorted_classi.select {|c| c.num_classe == 4}
      @classi_quarte
    end
  end

  def classi_quinte
    @classi_quinte ||= begin
      @classi_quinte = []
      @classi_quinte = sorted_classi.select {|c| c.num_classe == 5}
      @classi_quinte
    end
  end

  def sorted_classi
    @sorted_classi = []
    orderClasse =  NSSortDescriptor.sortDescriptorWithKey("num_classe", ascending:true)
    orderSezione = NSSortDescriptor.sortDescriptorWithKey("sezione",    ascending:true)
    @sorted_classi = @cliente.classi.sortedArrayUsingDescriptors([orderClasse, orderSezione])
    @sorted_classi
  end

  def numberOfSectionsInCollectionView(collectionView)
    5
  end


  def collectionView(collectionView, numberOfItemsInSection:section)
    case section
    when 0
      classi_prime.count
    when 1
      classi_seconde.count
    when 2
      classi_terze.count
    when 3
      classi_quarte.count
    when 4
      classi_quinte.count
    end
  end

  def collectionView(collectionView, cellForItemAtIndexPath:indexPath)
    
    cell = collectionView.dequeueReusableCellWithReuseIdentifier("classeItem", forIndexPath:indexPath)
    case indexPath.section
    when 0
      cell.classe = classi_prime[indexPath.row]
    when 1
      cell.classe = classi_seconde[indexPath.row]
    when 2
      cell.classe = classi_terze[indexPath.row]
    when 3
      cell.classe = classi_quarte[indexPath.row]
    when 4
      cell.classe = classi_quinte[indexPath.row]
    end
  
    cell
  end

  def collectionView(collectionView, didSelectItemAtIndexPath:indexPath)
    
    case indexPath.section
    when 0
      classe = classi_prime[indexPath.row]
    when 1
      classe = classi_seconde[indexPath.row]
    when 2
      classe = classi_terze[indexPath.row]
    when 3
      classe = classi_quarte[indexPath.row]
    when 4
      classe = classi_quinte[indexPath.row]
    end

    self.selected_classi << classe

    cell = collectionView.cellForItemAtIndexPath(indexPath)
    cell.setNeedsDisplay
  end

  def collectionView(collectionView, didDeselectItemAtIndexPath:indexPath)
    
    case indexPath.section
    when 0
      classe = classi_prime[indexPath.row]
    when 1
      classe = classi_seconde[indexPath.row]
    when 2
      classe = classi_terze[indexPath.row]
    when 3
      classe = classi_quarte[indexPath.row]
    when 4
      classe = classi_quinte[indexPath.row]
    end

    self.selected_classi.removeObject(classe)

    cell = collectionView.cellForItemAtIndexPath(indexPath)
    cell.setNeedsDisplay
  end

end

