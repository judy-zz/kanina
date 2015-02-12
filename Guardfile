guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/lib/#{m[1]}_spec.rb" }
  watch('spec/spec_helper.rb')  { 'spec' }
end

# # TODO: Uncomment this to regenerate docs locally, AFTER Yardoc is fixed
# # post-Ruby 2.2.0
# guard 'yard', port: '8808' do
#   watch(%r{lib/.+\.rb})
# end
