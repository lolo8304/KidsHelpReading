package com.kids.reading.selenium;

import java.io.File;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

import org.junit.Assert;
import org.openqa.selenium.By;
import org.openqa.selenium.OutputType;
import org.openqa.selenium.TakesScreenshot;
import org.openqa.selenium.WebElement;
import org.openqa.selenium.remote.Augmenter;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.remote.RemoteWebDriver;
import org.uiautomation.ios.IOSCapabilities;

public class TestSelenium {

public static void main(String[] args) throws MalformedURLException {
    // create a selenium desiredCapabilities object with the right values.
    DesiredCapabilities cap = IOSCapabilities.iphone();
    // start the application
    RemoteWebDriver driver = new RemoteWebDriver(new URL("http://localhost:4444/wd/hub"), cap);

    // check that the 9 mountains of the app are there.
    List<WebElement> cells = driver.findElements(By.className("UIATableCell"));
    Assert.assertEquals(9,cells.size());


    // get the 1st mountain
    WebElement first = cells.get(0);
    first.click();

    // take a screenshot using the normal selenium api.
    TakesScreenshot screen =(TakesScreenshot)new Augmenter().augment(driver);
    File ss = new File("screenshot.png");
    screen.getScreenshotAs(OutputType.FILE).renameTo(ss);
    System.out.println("screenshot take :"+ss.getAbsolutePath());

    // access the content
    By selector = By.xpath("//UIAStaticText[contains(@name,'climbed')]");
    WebElement text = driver.findElement(selector);
    System.out.println(text.getAttribute("name"));

    // end the test
    driver.quit();
    }

}