<?php namespace Dummy\Dummy;

class DummyTest extends \Codeception\Test\Unit
{
    /**
     * @var \Dummy\Dummy\UnitTester
     */
    protected $tester;

    protected function _before()
    {
    }

    protected function _after()
    {
    }

    public function testGetMagicNumber()
    {
        $actual = Dummy::getMagicNumber();
        $this->assertSame(42, $actual);
    }
}
