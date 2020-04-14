<?php

namespace Newbury\VagrantSetup;

use Newbury\VagrantSetup\Frameworks\FrameworkHandler;
use Symfony\Component\Console\Command\Command;
use Symfony\Component\Console\Input\InputInterface;
use Symfony\Component\Console\Output\OutputInterface;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Console\Question\ChoiceQuestion;
use Symfony\Component\Console\Question\Question;

class Setup extends Command
{
    /** @var string */
    private $destinationDirectory;
    /** @var Filesystem */
    private $fileSystem;

    const FRAMEWORKS = ['Magento'];

    /**
     * Configure the command options.
     *
     * @return void
     */
    protected function configure()
    {
        $this->setName('new')
            ->setDescription('Create a new local Vagrant environment');
    }

    /**
     * Execute the command.
     *
     * @param  \Symfony\Component\Console\Input\InputInterface  $input
     * @param  \Symfony\Component\Console\Output\OutputInterface  $output
     * @return int
     */
    protected function execute(InputInterface $input, OutputInterface $output)
    {
        $this->init();
        $helper = $this->getHelper('question');
        $projectNameQuestion = new Question('Name of your project: ');
        $projectName = $helper->ask($input, $output, $projectNameQuestion);

        $domainQuestion = new Question('Domain name (We recommend a domain ending .test): ');
        $domain = $helper->ask($input, $output, $domainQuestion);

        $memoryQuestion = new Question('Memory (recommend 2048): ', '2048');
        $memory = $helper->ask($input, $output, $memoryQuestion);

        $typeQuestion = new ChoiceQuestion(
            'Project type:',
            self::FRAMEWORKS
        );
        $typeQuestion->setErrorMessage('Invalid project type');

        $handler = $this->getFrameworkHandler(
            $helper->ask($input, $output, $typeQuestion)
        );
        $files = $handler->getFiles();

        foreach ($files as $path => $data) {
            if ('vagrant.yaml' === $path) {
                $data = str_replace(
                    ['$YOUR_PROJECT', '$DOMAIN', '$MEMORY'],
                    [$projectName, $domain, $memory],
                    $data
                );
            }
            $this->fileSystem->dumpFile($path, $data);
        }
        $output->writeln('<info>Generated file for Vagrant environment</info>');
        return 0;
    }

    /**
     * Determine required location paths and load dependencies
     */
    private function init()
    {
        $this->destinationDirectory = getcwd();
        $this->fileSystem = new Filesystem();
    }

    /**
     * @param $framework
     * @return FrameworkHandler
     */
    private function getFrameworkHandler($framework): FrameworkHandler
    {
        $className = "\\Newbury\\VagrantSetup\\Frameworks\\$framework";
        $path = __DIR__ . '/../resources/' . $framework;
        return new $className($path);
    }
}
