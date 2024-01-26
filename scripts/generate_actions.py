#!/usr/bin/env python3

"""
generate_actions.py

Generate GitHub Actions workflow files for WinterCMS images

usage:
    generate_actions.py <template> <images_dir> <output_dir>
"""

import os
from argparse import ArgumentParser
from jinja2 import Environment, FileSystemLoader


# main
if __name__ == '__main__':
    parser = ArgumentParser(
        description='Generate GitHub Actions workflow files for WinterCMS images')
    # required arguments
    parser.add_argument(
        'template', default='templates/actions.yml.j2', help='Template file')
    parser.add_argument('images_dir', default='images',
                        help='Images directory')
    parser.add_argument('output_dir', default='.github/workflows',
                        help='Output directory')

    # optional arguments
    args = parser.parse_args()

    # Load templates from the current directory
    env = Environment(loader=FileSystemLoader(os.path.dirname(args.template)))
    template = env.get_template(os.path.basename(args.template))

    # search for all dockerfiles in the images directory keeping track of the folder paths for tags
    images_tags = []
    for root, dirs, files in os.walk(args.images_dir):
        # if a dockerfile is found, add the folder path to the list of tags
        # remove the 'images/' prefix and replace the '/' with '-'
        # keep the file name to template the dockerfile in later
        if 'Dockerfile' in files:
            images_tags.append({
                'tag': root.removeprefix(
                    args.images_dir + '/').removeprefix('php-').replace('/', '-'),
                'dockerfile': os.path.join(root, 'Dockerfile'),
            })

    # generate and save the generated workflow files for each image
    for im in images_tags:
        # create an action file name based on the image tag
        action_name = "{}.yml".format(im['tag'])

        # variables to substitute in the template
        vars = {
            "TEMPLATE_TAG": im['tag'],
            "TEMPLATE_DOCKERFILE": im['dockerfile'],
            "TEMPLATE_DOCKER_CONTEXT": os.path.dirname(args.template),
        }

        # render the template with the variables
        workflow = template.render(vars)

        # save the generated workflow file
        with open(os.path.join(args.output_dir, action_name), 'w') as f:
            f.write(workflow)

    print("Done!")
