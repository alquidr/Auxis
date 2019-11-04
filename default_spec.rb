# Unit Tests with chefspec
require 'chefspec'

describe 'tomcat::default' do
    let(:chef_run) { ChefSpec::SoloRunner.converge(described_recipe) }

    it 'installs nginx server.' do
        expect(chef_run).to install_yum_package('nginx')
    end
    
        it 'Inizialize the nginx service.' do
            expect(chef_run).to start_service('nginx')
        end
end
  