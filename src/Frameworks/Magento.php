<?php

namespace Newbury\VagrantSetup\Frameworks;

class Magento extends FrameworkHandler
{
    public function getFiles()
    {
        return [
            'vagrant/env.php.dist' => $envfile = file_get_contents($this->resourcePath . '/env.php.dist'),
            'vagrant/install.sh' => $installSh = file_get_contents($this->resourcePath . '/install.sh'),
            'vagrant/local.sql.dist' => $localSql = file_get_contents($this->resourcePath . '/local.sql.dist'),
            'vagrant/magento.conf.dist' => $magentoConf = file_get_contents($this->resourcePath . '/magento.conf.dist'),
            'nginx.conf' => $nginxConf = file_get_contents($this->resourcePath . '/nginx.conf'),
            'vagrant.yaml' => $vagrantYaml = file_get_contents($this->resourcePath . '/vagrant.yaml'),
            'Vagrantfile' => $vagrantfile = file_get_contents($this->resourcePath . '/Vagrantfile'),
            'xoff' => $xon = file_get_contents($this->resourcePath . '/../xoff'),
            'xon' => $xoff = file_get_contents($this->resourcePath . '/../xon'),
        ];
    }
}
