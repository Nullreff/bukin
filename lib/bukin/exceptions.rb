module Bukin
  class BukinError < StandardError; end
  class BukfileError < BukinError; end
  class InstallError < BukinError; end
end
