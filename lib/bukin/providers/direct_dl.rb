
# Api for direct downloads
class Bukin::DirectDl
  def usable(data)
    !!data[:download]
  end

  def resolve_info(data)
    data[:display_version] = data[:version]
    data
  end
end
