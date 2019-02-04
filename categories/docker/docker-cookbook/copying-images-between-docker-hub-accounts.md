# Copy across images from one docker hub account to another

```bash
docker pull {source_account_name}/{image_name}:{tag}
docker tag {source_account_name}/{image_name}:{tag} codingbee/{new_image_name}:{new_tag}
docker push codingbee/{new_image_name}:{new_tag}
```