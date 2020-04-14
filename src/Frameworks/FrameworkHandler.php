<?php

namespace Newbury\VagrantSetup\Frameworks;

abstract class FrameworkHandler
{
    /** @var string */
    protected $resourcePath;

    /**
     * Laravel constructor.
     * @param string $resourcePath
     */
    public function __construct(string $resourcePath)
    {
        $this->resourcePath = $resourcePath;
    }

    abstract public function getFiles();
}
