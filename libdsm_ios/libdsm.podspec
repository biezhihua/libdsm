# Pod::Spec.new do |s|
#     header_search_paths = [
#         '/Users/biezhihua/StudySpace/libdsm/libdsm_core/',
#         '/Users/biezhihua/StudySpace/libdsm/libdsm_core/nlohmann/',
#         '/Users/biezhihua/StudySpace/libdsm/distribution/ios/libdsm/include/'
#     ]

#     library_search_paths = [
#         '/Users/biezhihua/StudySpace/libdsm/distribution/ios/libdsm/lib/'
#     ]

#     s.source_files     = 'libdsm_ios/*.h', 'libdsm_ios/*.swift', 'libdsm_ios/*.map', 'libdsm_ios/birdge/*', 'libdsm_core/*.cpp'

#     s.name             = 'libdsm'
#     s.version          = '1.1.0'
#     s.summary          = 'An iOS wrapper for the libdsm library.'
#     s.description      = <<-DESC
# An iOS wrapper for the libdsm library.
# An iOS wrapper for the libdsm library.
#                          DESC
#     s.homepage         = 'https://github.com/biezhihua/libdsm_ios'
#     s.license          = { :type => "Apache", :file => "./LICENSE" }
#     s.author           = { 'biezhihua' => 'biezhihua@gmail.com' }
#     s.source           = { :git => "https://github.com/biezhihua/libdsm_ios.git", :tag => "#{s.version}" }
    
#     s.platform = :ios, '11.0'
  
#     # Flutter.framework does not contain a i386 slice. Only x86_64 simulators are supported.
#     s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES',
#      'VALID_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
#      'SWIFT_INCLUDE_PATHS' => 'libdsm/libdsm_ios',
#      'HEADER_SEARCH_PATHS' => header_search_paths.join(' '),
#      'LIBRARY_SEARCH_PATHS' => library_search_paths.join(' '),
#     }
#     s.swift_version = '5.0'
# end
