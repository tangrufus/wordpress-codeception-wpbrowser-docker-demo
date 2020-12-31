<?php
namespace Dummy\Dummy;

class DummyTest extends \Codeception\TestCase\WPTestCase
{
    /**
     * @var \WpunitTester
     */
    protected $tester;

    public function setUp(): void
    {
        // Before...
        parent::setUp();

        // Your set up methods here.
    }

    public function tearDown(): void
    {
        // Your tear down methods here.

        // Then...
        parent::tearDown();
    }

    public function testGetSanitizeTextMagic()
    {
        $actual = Dummy::getQuestion();
        $expected = 'The Answer to the Great Question of Life, the Universe and Everything: Forty-two.';
        $this->assertSame($expected, $actual);
    }
}
