require File.expand_path('../../../util/pe_ini_file', __FILE__)
require File.expand_path('../../../util/setting_value', __FILE__)

Puppet::Type.type(:pe_ini_subsetting).provide(:ruby) do

  def exists?
    setting_value.get_subsetting_value(subsetting)
  end

  def create
    setting_value.add_subsetting(subsetting, resource[:value])
    pe_ini_file.set_value(section, setting, setting_value.get_value)
    pe_ini_file.save
    @pe_ini_file = nil
    @setting_value = nil
  end

  def destroy
    setting_value.remove_subsetting(subsetting)
    pe_ini_file.set_value(section, setting, setting_value.get_value)
    pe_ini_file.save
    @pe_ini_file = nil
    @setting_value = nil
  end

  def value
    setting_value.get_subsetting_value(subsetting)
  end

  def value=(value)
    setting_value.add_subsetting(subsetting, resource[:value])
    pe_ini_file.set_value(section, setting, setting_value.get_value)
    pe_ini_file.save
  end

  def section
    resource[:section]
  end

  def setting
    resource[:setting]
  end

  def subsetting
    resource[:subsetting]
  end

  def subsetting_separator
    resource[:subsetting_separator]
  end

  def file_path
    resource[:path]
  end

  def separator
    resource[:key_val_separator] || '='
  end

  def quote_char
    resource[:quote_char]
  end

  private
  def pe_ini_file
    @pe_ini_file ||= Puppet::Util::PeIniFile.new(file_path, separator)
  end

  def setting_value
    @setting_value ||= Puppet::Util::SettingValue.new(pe_ini_file.get_value(section, setting), subsetting_separator, quote_char)
  end

end
