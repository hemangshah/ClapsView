Pod::Spec.new do |s|
s.name             = 'ClapsView'
s.module_name      = 'ClapsView'
s.version          = '1.0.0'
s.summary          = 'Implemented the functionality of Medium.com Claps. 👏'
s.description      = 'ClapsView is a new way to give your ratings or feedback from your users.'
s.homepage         = 'https://github.com/hemangshah/ClapsView'
s.license          = 'MIT'
s.author           = { 'hemangshah' => 'hemangshah.in@gmail.com' }
s.source           = { :git => 'https://github.com/hemangshah/ClapsView.git', :tag => s.version.to_s }
s.platform     = :ios, '9.0'
s.requires_arc = true
s.source_files = '**/ClapsView.swift'
end
