defmodule FarmbotOS.Configurator.DataLayer do
  # "net_config_dns_name" => String.t()
  # "net_config_ntp1" => String.t()
  # "net_config_ntp2" => String.t()
  # "net_config_ssh_key" => String.t()
  # "net_config_ssid" => String.t()
  # "net_config_security" => String.t()
  # "net_config_psk" => String.t()
  # "net_config_identity" => String.t()
  # "net_config_password" => String.t()
  # "net_config_domain" => String.t()
  # "net_config_name_servers" => String.t()
  # "net_config_ipv4_method" => String.t()
  # "net_config_ipv4_address" => String.t()
  # "net_config_ipv4_gateway" => String.t()
  # "net_config_ipv4_subnet_mask" => String.t()
  # "net_config_reg_domain" => String.t()
  # "auth_config_email" => String.t()
  # "auth_config_password" => String.t()
  # "auth_config_server" => String.t()
  @type conf :: %{
          required(String.t()) => nil | String.t()
        }

  @callback load_last_reset_reason() :: nil | String.t()
  @callback load_email() :: nil | String.t()
  @callback load_password() :: nil | String.t()
  @callback load_server() :: nil | String.t()
  @callback dump_logs() :: [map()]
  @callback dump_log_db() :: {:error, File.posix()} | binary()
  @callback save_config(conf) :: any()
end