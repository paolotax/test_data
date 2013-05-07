class ModalNavigationController < UINavigationController

	# per nascondere la tastiera nelle modali
  def disablesAutomaticKeyboardDismissal
    false
  end

end