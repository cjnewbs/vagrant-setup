<?php

namespace Newbury\VagrantSetup\Frameworks;

class Laravel extends FrameworkHandler
{
    public function getFiles()
    {
        return [
            'vagrant/install.sh' => $installSh = file_get_contents($this->resourcePath . '/install.sh'),
            'vagrant/local.sql.dist' => $localSql = file_get_contents($this->resourcePath . '/local.sql.dist'),
            'laravel.conf' => $nginxConf = file_get_contents($this->resourcePath . '/laravel.conf'),
            'vagrant.yaml' => $vagrantYaml = file_get_contents($this->resourcePath . '/vagrant.yaml'),
            'Vagrantfile' => $vagrantfile = file_get_contents($this->resourcePath . '/Vagrantfile'),
            'xoff' => $xon = file_get_contents($this->resourcePath . '/../xoff'),
            'xon' => $xoff = file_get_contents($this->resourcePath . '/../xon'),
        ];
    }
}
