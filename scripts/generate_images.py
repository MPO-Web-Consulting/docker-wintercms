#!/usr/bin/env python3

"""
generate_images.py

Generate Dockerfiles for WinterCMS images

Usage:
    generate_images.py <template> <output_dir> <images>
"""

import os
from argparse import ArgumentParser
from jinja2 import Environment, FileSystemLoader
import yaml


# main
if __name__ == '__main__':
    parser = ArgumentParser(
        description='Generate Dockerfiles for WinterCMS images')
    # required arguments
    parser.add_argument(
        'template', default='templates/Dockerfile.j2', help='Template file')
    parser.add_argument('output_dir', default='images',
                        help='Output directory')
    parser.add_argument('images', default='images.yaml', help='Images file')

    # optional arguments
    args = parser.parse_args()

    # Load templates from the current directory
    env = Environment(loader=FileSystemLoader(os.path.dirname(args.template)))
    template = env.get_template(os.path.basename(args.template))

    # load the images file
    with open(args.images, 'r') as f:
        images = yaml.safe_load(f)

    # generate and save the generated Dockerfiles for each image
    for winter_version in images['wintercms_versions']:
        for php_version in winter_version['php_versions']:
            for php_variant in winter_version['php_variants']:
                # create the output directory if it doesn't exist
                dir = os.path.join(args.output_dir, "php-{}".format(php_version), php_variant, "v{}".format(
                    winter_version['tag']))
                os.makedirs(dir, exist_ok=True)

                # variables to substitute in the template
                vars = {
                    'TEMPLATE_PHP_VERSION': php_version,
                    'TEMPLATE_PHP_VARIANT': php_variant,
                    'TEMPLATE_WINTERCMS_VERSION': winter_version['tag'],
                    # command to run when the container starts, apache2-foreground for apache and php-fpm for php-fpm
                    'TEMPLATE_COMMAND': 'apache2-foreground' if php_variant == 'apache' else 'php-fpm',
                }

                # render the template with the variables
                dockerfile = template.render(vars)

                # save the generated Dockerfile
                with open(os.path.join(dir, 'Dockerfile'), 'w') as f:
                    f.write(dockerfile)

    print('Done!')
