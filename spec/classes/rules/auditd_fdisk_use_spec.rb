# frozen_string_literal: true

require 'spec_helper'

enforce_options = [true, false]

describe 'cis_security_hardening::rules::auditd_fdisk_use' do
  let(:pre_condition) do
    <<-EOF
    class {'cis_security_hardening::rules::auditd_init':
      rules_file => '/etc/audit/rules.d/cis_security_hardening.rules',
    }

    reboot { 'after_run':
      timeout => 60,
      message => 'forced reboot by Puppet',
      apply   => 'finished',
    }
    EOF
  end

  on_supported_os.each do |os, os_facts|
    enforce_options.each do |enforce|
      context "on #{os} with enforce = #{enforce}" do
        let(:facts) do
          os_facts.merge!(
            cis_security_hardening: {
              auditd: {
                auditing_process: 'none',
              },
            },
          )
        end
        let(:params) do
          {
            'enforce' => enforce,
          }
        end

        it {
          is_expected.to compile

          if enforce
            is_expected.to contain_concat__fragment('watch fdisk command rule 1')
              .with(
                'order'   => '195',
                'target'  => '/etc/audit/rules.d/cis_security_hardening.rules',
                'content' => '-w /bin/fdisk -p x -k fdisk',
              )
          else
            is_expected.not_to contain_concat__fragment('watch fdisk command rule 1')
          end
        }
      end
    end
  end
end
