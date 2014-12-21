<?php
$directory = "captures/";
$dateFormat = "F j, Y, g:i a";



$files = array();

$ignored = array('.', '..', '.svn', '.htaccess');

    foreach (scandir($directory) as $file) {
        if (in_array($file, $ignored)) continue;
        $files[$file] = filemtime($directory . '/' . $file);
    }

    arsort($files);
    $files = array_keys($files);


$date_array = array();

$mtime;

for ($i=0; $i <count($files); $i++)
{
    

$mtime = date ($dateFormat, filemtime($directory . $files[$i]));

$date_array[] = $mtime;

}

function print_date($picNum)
{

    global $files, $date_array;
if($picNum < count($files))
{
echo ($date_array[$picNum]);
}
}


function pic_location($PicNum)
{
    global $files, $directory;
if($PicNum < count($files))
{
echo ($directory . $files[$PicNum]);
}

else
{
echo "parallella.jpg";
}

}


function print_name($num)
{
global $files;
if($num < count($files))
{

echo($files[$num]);

}

}



?>


<!DOCTYPE html>
<html lang="en">

<head>

    <meta charset="utf-8">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="description" content="">
    <meta name="author" content="">

    <title>3 Col Portfolio - Start Bootstrap Template</title>

    <!-- Bootstrap Core CSS -->
    <link href="css/bootstrap.min.css" rel="stylesheet">

    <!-- Custom CSS -->
    <link href="css/3-col-portfolio.css" rel="stylesheet">

    <!-- HTML5 Shim and Respond.js IE8 support of HTML5 elements and media queries -->
    <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
    <!--[if lt IE 9]>
        <script src="https://oss.maxcdn.com/libs/html5shiv/3.7.0/html5shiv.js"></script>
        <script src="https://oss.maxcdn.com/libs/respond.js/1.4.2/respond.min.js"></script>
    <![endif]-->

</head>

<body>

    <!-- Navigation -->
    <nav class="navbar navbar-inverse navbar-fixed-top" role="navigation">
        <div class="container">
            <!-- Brand and toggle get grouped for better mobile display -->
            <div class="navbar-header">
                <button type="button" class="navbar-toggle" data-toggle="collapse" data-target="#bs-example-navbar-collapse-1">
                    <span class="sr-only">Toggle navigation</span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                    <span class="icon-bar"></span>
                </button>
                <a class="navbar-brand" href="#">Home</a>
            </div>
            <!-- Collect the nav links, forms, and other content for toggling -->
            <div class="collapse navbar-collapse" id="bs-example-navbar-collapse-1">
                <ul class="nav navbar-nav">
                    <li>
                        <a href="captures/">All Images</a>
                    </li>
                    <li>
                        <a href="https://www.youtube.com/channel/UCtyUJ0PSiYugIQ087aLGRBw">YouTube</a>
                    </li>
                    <li>
                        <a href="http://www.parallella.org/">Parallella</a>
                    </li>
                    <li>
                        <a href="https://github.com/parallella/parallella-examples">GitHub</a>
                    </li>
                </ul>
            </div>
            <!-- /.navbar-collapse -->
        </div>
        <!-- /.container -->
    </nav>

    <!-- Page Content -->
    <div class="container">

        <!-- Page Header -->
        <div class="row">
            <div class="col-lg-12">
                <h1 class="page-header">Captured Images
                    <small>These are your latest captured images</small>
                </h1>
            </div>
        </div>
        <!-- /.row -->

        <!-- Projects Row -->
        <div class="row">
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(0); ?>">
                    <img class="img-responsive" src="<?php pic_location(0); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(0); ?>"><?php print_name(0); ?></a></h3>
                <p><?php print_date(0); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(1); ?>">
                    <img class="img-responsive" src="<?php pic_location(1); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(1); ?>"><?php print_name(1); ?></a></h3>
                <p><?php print_date(1); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(2); ?>">
                    <img class="img-responsive" src="<?php pic_location(2); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(2); ?>"><?php print_name(2); ?></a></h3>
                <p><?php print_date(2); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(3); ?>">
                    <img class="img-responsive" src="<?php pic_location(3); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(3); ?>"><?php print_name(3); ?></a></h3>
                <p><?php print_date(3); ?></p>
            </div>
        </div>
        <!-- /.row -->

        <!-- Projects Row -->
        <div class="row">
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(4); ?>">
                    <img class="img-responsive" src="<?php pic_location(4); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(4); ?>"><?php print_name(4); ?></a></h3>
                <p><?php print_date(4); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(5); ?>">
                    <img class="img-responsive" src="<?php pic_location(5); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(5); ?>"><?php print_name(5); ?></a></h3>
                <p><?php print_date(5); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(6); ?>">
                    <img class="img-responsive" src="<?php pic_location(6); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(6); ?>"><?php print_name(6); ?></a></h3>
                <p><?php print_date(6); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(7); ?>">
                    <img class="img-responsive" src="<?php pic_location(7); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(7); ?>"><?php print_name(7); ?></a></h3>
                <p><?php print_date(7); ?></p>
            </div>
        </div>

        <!-- Projects Row -->
        <div class="row">
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(8); ?>">
                    <img class="img-responsive" src="<?php pic_location(8); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(8); ?>"><?php print_name(8); ?></a></h3>
                <p><?php print_date(8); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(9); ?>">
                    <img class="img-responsive" src="<?php pic_location(9); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(9); ?>"><?php print_name(9); ?></a></h3>
                <p><?php print_date(9); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(10); ?>">
                    <img class="img-responsive" src="<?php pic_location(10); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(10); ?>"><?php print_name(10); ?></a></h3>
                <p><?php print_date(10); ?></p>
            </div>
            <div class="col-md-3 portfolio-item">
                <a href="<?php pic_location(11); ?>">
                    <img class="img-responsive" src="<?php pic_location(11); ?>" alt="">
                </a>
                <h3><a href="<?php pic_location(11); ?>"><?php print_name(11); ?></a></h3>
                <p><?php print_date(11); ?></p>
            </div>
        </div>
        <!-- /.row -->

       

        <!-- Footer -->
        <footer>
            <div class="row">
                <div class="col-lg-12">
                    <p>Copyright &copy; Aaron Wisner 2014 aaronwisner@gmail.com</p>
                </div>
            </div>
            <!-- /.row -->
        </footer>

    </div>
    <!-- /.container -->

    <!-- jQuery -->
    <script src="js/jquery.js"></script>

    <!-- Bootstrap Core JavaScript -->
    <script src="js/bootstrap.min.js"></script>

</body>

</html>
