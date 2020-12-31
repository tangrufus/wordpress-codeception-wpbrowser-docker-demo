<?php namespace Dummy\Dummy;
use Dummy\Dummy\FunctionalTester;

class DummyAdminNoticeCest
{
    public function _before(FunctionalTester $I)
    {
    }

    public function seeAdminNotice(FunctionalTester $I)
    {
        $I->loginAsAdmin();
        $I->amOnAdminPage('/');
        $I->see('What is the Answer to the Great Question of Life, the Universe and Everything?');
    }
}
