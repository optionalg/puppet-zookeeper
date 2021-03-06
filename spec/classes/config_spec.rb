require 'spec_helper'

describe 'zookeeper::config', :type => :class do

  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
  }}

  shared_examples 'common' do |os, codename|
    let(:facts) {{
      :operatingsystem => os,
      :osfamily => 'Debian',
      :lsbdistcodename => codename,
    }}

    it { should contain_file(cfg_dir).with({
      'ensure'  => 'directory',
      'owner'   => user,
      'group'   => group,
    }) }

    it { should contain_file(log_dir).with({
      'ensure'  => 'directory',
      'owner'   => user,
      'group'   => group,
    }) }

    it { should contain_file(id_file).with({
      'ensure'  => 'file',
      'owner'   => user,
      'group'   => group,
    }).with_content(myid) }

    context 'extra parameters' do
      snap_cnt = 15000
      # set custom params
      let(:params) { {
        :log4j_prop    => 'ERROR',
        :snap_count    => snap_cnt,
      } }

      it {
        should contain_file('/etc/zookeeper/conf/environment').with_content(/ERROR/)
      }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/snapCount=15000/)
      }
    end

    context 'max allowed connections' do
      max_conn = 15

      let(:params) {{
        :max_allowed_connections => max_conn
      }}

      it { should contain_file(
          '/etc/zookeeper/conf/zoo.cfg'
        ).with_content(/maxClientCnxns=#{max_conn}/) }
    end

    context 'set client ip address' do
      ipaddress = '192.168.1.1'
      let(:params){{
        :client_ip => ipaddress
      }}

      it { should contain_file(
        '/etc/zookeeper/conf/zoo.cfg'
      ).with_content(/clientPortAddress=#{ipaddress}/) }
    end


    context 'quorum file' do
      ipaddress = '192.168.1.1'
      let(:facts) {{
        :operatingsystem => os,
        :osfamily => 'Debian',
        :lsbdistcodename => codename,
        :ipaddress => ipaddress
      }}

      it { should create_datacat_fragment('192.168.1.1').with_data(
        {"id"=>myid, "client_ip"=>"192.168.1.1", "election_port"=>"2888", "leader_port"=>"3888"}
      )}
    end

    #  it { should contain_file(
    #    '/etc/zookeeper/conf/quorum.yml'
    #  )}
    #it { should contain_datacat__fragment("#{ipaddress}") }

    #  it { should contain_concat__fragment("zookeeper_#{ipaddress}") }

    context 'setting tick time' do
      tick_time = 3000
      let(:params) { {
        :tick_time => tick_time,
      } }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/tickTime=#{tick_time}/)
      }
    end

    context 'setting init and sync limit' do
      init_limit = 15
      sync_limit = 10
      let(:params) { {
        :init_limit => init_limit,
        :sync_limit => sync_limit,
      } }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/initLimit=#{init_limit}/)
      }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/syncLimit=#{sync_limit}/)
      }
    end

    context 'setting leader' do
      let(:params) { {
        :leader => false,
      } }

      it {
        should contain_file('/etc/zookeeper/conf/zoo.cfg').with_content(/leaderServes=no/)
      }
    end
  end

  context 'on debian-like system' do
    let(:user)    { 'zookeeper' }
    let(:group)   { 'zookeeper' }
    let(:cfg_dir) { '/etc/zookeeper/conf' }
    let(:log_dir) { '/var/lib/zookeeper' }
    let(:id_file) { '/etc/zookeeper/conf/myid' }
    let(:myid)    { /1/ }

    it_behaves_like 'common', 'Debian', 'wheezy'
  end

  context 'custom parameters' do
    # set custom params
    let(:params) { {
      :id      => '2',
      :user    => 'zoo',
      :group   => 'zoo',
      :cfg_dir => '/var/lib/zookeeper/conf',
      :log_dir => '/var/lib/zookeeper/log',
    } }

    let(:user)    { 'zoo' }
    let(:group)   { 'zoo' }
    let(:cfg_dir) { '/var/lib/zookeeper/conf' }
    let(:log_dir) { '/var/lib/zookeeper/log' }
    let(:id_file) { '/var/lib/zookeeper/conf/myid' }
    let(:myid)    { /2/ }

    it_behaves_like 'common', 'Debian', 'wheezy'
  end

  context 'myid link' do

    it { should contain_file(
      '/var/lib/zookeeper/myid'
    ).with({
      'ensure' => 'link',
      'target' => '/etc/zookeeper/conf/myid',
    })}
  end

end
