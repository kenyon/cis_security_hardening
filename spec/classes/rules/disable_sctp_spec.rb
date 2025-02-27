# frozen_string_literal: true

require 'spec_helper'

enforce_options = [true, false]

describe 'cis_security_hardening::rules::disable_sctp' do
  on_supported_os.each do |os, os_facts|
    enforce_options.each do |enforce|
      context "on #{os}" do
        let(:facts) { os_facts }
        let(:params) do
          {
            'enforce' => enforce,
          }
        end

        it {
          is_expected.to compile

          if enforce
            if (os_facts[:os]['name'].casecmp('debian').zero? && os_facts[:os]['release']['major'] > '10') ||
               (os_facts[:os]['name'].casecmp('ubuntu').zero? && os_facts[:os]['release']['major'] >= '22')
              cmd = '/bin/false'
              is_expected.to contain_kmod__blacklist('sctp')
            else
              cmd = '/bin/true'
            end

            is_expected.to contain_kmod__install('sctp')
              .with(
                command: cmd,
              )
          else
            is_expected.not_to contain_kmod__install('sctp')
          end
        }
      end
    end
  end
end
