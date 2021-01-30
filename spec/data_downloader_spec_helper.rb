def delete_local_files
  local_Status = "#{Dir.tmpdir}/vatsim_online/vatsim_status.json"
  lOCAL_DATA = "#{Dir.tmpdir}/vatsim_online/vatsim_data.json"
  if File.exists?(local_Status)
    File.delete(local_Status)
  end
  if File.exists?(lOCAL_DATA)
    File.delete(lOCAL_DATA)
  end
end
